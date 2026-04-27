#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "fatfs.h"
#include "main.h"
#include "usb_host.h"

#include "display.h"
#include "i2s.h"
#include "input.h"
#include "wav_list.h"
#include "wav_stream.h"
#include "wm8731.h"

extern ApplicationTypeDef Appli_state;

static const int8_t VOLUME_LEVELS_DB[] = {-42, -30, -18};
static size_t volume_level_index = 0;
static size_t track_index = 0;

static bool find_and_open_wav_stream(size_t index) {
  for (size_t i = index; i < app_wav_list_get_len(); ++i) {
    const char *name = app_wav_list_get_name_by_index(i);
    if (app_wav_stream_open(name)) {
      track_index = i;
      return true;
    }
  }
  track_index = 0;
  return false;
}

static bool stop_and_close_wav_stream(void) {
  app_i2s_set_state(APP_I2S_STATE_STOPPED);
  if (!app_i2s_sync_state()) { // 確実に止める
    return false;
  }
  app_wav_stream_close();
  return true;
}

static bool fill_i2s_tx_buf(app_i2s_buf_type_t buf_type) {
  uint16_t *buf = app_i2s_get_tx_buf(buf_type);
  int res = app_wav_stream_read(buf, APP_I2S_SAMPLES);
  if (res < 0) {
    return false;
  }
  if (res > 0) {
    app_i2s_set_tx_buf_filled(buf_type);
  }
  return true;
}

void app_main(void) {
  while (Appli_state != APPLICATION_READY) {
    MX_USB_HOST_Process();
  }
  if (f_mount(&USBHFatFS, USBHPath, 1) != FR_OK) {
    Error_Handler();
  }
  if (!app_wav_list_init(USBHPath)) {
    Error_Handler();
  }
  if (!app_wm8731_init()) {
    Error_Handler();
  }

  while (true) {
    switch (app_input_get_event()) {
    case APP_INPUT_EVENT_PLAY_PAUSE:
      switch (app_i2s_get_state()) {
      case APP_I2S_STATE_STOPPED:
        if (!find_and_open_wav_stream(track_index)) {
          Error_Handler();
        }
        if (!fill_i2s_tx_buf(APP_I2S_BUF_FIRST_HALF)) {
          Error_Handler();
        }
        if (!fill_i2s_tx_buf(APP_I2S_BUF_SECOND_HALF)) {
          Error_Handler();
        }
        app_i2s_set_state(APP_I2S_STATE_PLAYING);
        break;
      case APP_I2S_STATE_PAUSED:
        app_i2s_set_state(APP_I2S_STATE_PLAYING);
        break;
      case APP_I2S_STATE_PLAYING:
        app_i2s_set_state(APP_I2S_STATE_PAUSED);
        break;
      case APP_I2S_STATE_COUNT:
        Error_Handler();
        break;
      }
      break;

    case APP_INPUT_EVENT_NEXT_TRACK:
      switch (app_i2s_get_state()) {
      case APP_I2S_STATE_STOPPED:
        if (!find_and_open_wav_stream(track_index)) {
          Error_Handler();
        }
        if (!fill_i2s_tx_buf(APP_I2S_BUF_FIRST_HALF)) {
          Error_Handler();
        }
        if (!fill_i2s_tx_buf(APP_I2S_BUF_SECOND_HALF)) {
          Error_Handler();
        }
        app_i2s_set_state(APP_I2S_STATE_PLAYING);
        break;
      case APP_I2S_STATE_PAUSED:
      case APP_I2S_STATE_PLAYING:
        if (!stop_and_close_wav_stream()) {
          Error_Handler();
        }
        if (find_and_open_wav_stream(track_index + 1)) {
          if (!fill_i2s_tx_buf(APP_I2S_BUF_FIRST_HALF)) {
            Error_Handler();
          }
          if (!fill_i2s_tx_buf(APP_I2S_BUF_SECOND_HALF)) {
            Error_Handler();
          }
          app_i2s_set_state(APP_I2S_STATE_PLAYING);
        }
        break;
      case APP_I2S_STATE_COUNT:
        Error_Handler();
        break;
      }
      break;

    case APP_INPUT_EVENT_VOLUME:
      volume_level_index =
          (volume_level_index + 1) %
          (sizeof(VOLUME_LEVELS_DB) / sizeof(VOLUME_LEVELS_DB[0]));
      break;

    default:
      break;
    }

    if (app_i2s_get_state() == APP_I2S_STATE_PLAYING) {
      if (app_wav_stream_is_eof() &&
          app_i2s_is_tx_buf_empty(APP_I2S_BUF_FIRST_HALF) &&
          app_i2s_is_tx_buf_empty(APP_I2S_BUF_SECOND_HALF)) {
        if (!stop_and_close_wav_stream()) {
          Error_Handler();
        }
        if (find_and_open_wav_stream(track_index + 1)) {
          if (!fill_i2s_tx_buf(APP_I2S_BUF_FIRST_HALF)) {
            Error_Handler();
          }
          if (!fill_i2s_tx_buf(APP_I2S_BUF_SECOND_HALF)) {
            Error_Handler();
          }
          app_i2s_set_state(APP_I2S_STATE_PLAYING);
        }
      } else if (!app_wav_stream_is_eof()) {
        if (app_i2s_is_tx_buf_empty(APP_I2S_BUF_FIRST_HALF)) {
          if (!fill_i2s_tx_buf(APP_I2S_BUF_FIRST_HALF)) {
            Error_Handler();
          }
        }
        if (app_i2s_is_tx_buf_empty(APP_I2S_BUF_SECOND_HALF)) {
          if (!fill_i2s_tx_buf(APP_I2S_BUF_SECOND_HALF)) {
            Error_Handler();
          }
        }
      }
    }

    if (!app_i2s_sync_state()) {
      Error_Handler();
    }

    (void)app_wm8731_set_volume(VOLUME_LEVELS_DB[volume_level_index]);
    app_display_set_digit(track_index + 1);

    MX_USB_HOST_Process();
  }
}
