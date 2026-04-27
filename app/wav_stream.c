#define DR_WAV_NO_STDIO
#define DR_WAV_IMPLEMENTATION

#include <string.h>

#include "ff.h"

#include "dr_wav.h"
#include "i2s.h"
#include "wav_stream.h"

static FIL wav_file;
static drwav wav;
static drwav_int16 wav_buf[APP_I2S_SAMPLES * APP_I2S_CHANNELS];

static size_t drwav_on_read_fatfs(void *pUserData, void *pBufferOut,
                                  size_t bytesToRead) {
  UINT len;
  if (f_read((FIL *)pUserData, pBufferOut, bytesToRead, &len) != FR_OK) {
    return 0;
  }
  return len;
}

static drwav_bool32 drwav_on_seek_fatfs(void *pUserData, int offset,
                                        drwav_seek_origin origin) {
  FSIZE_t base = 0;
  switch (origin) {
  case DRWAV_SEEK_SET:
    base = 0;
    break;
  case DRWAV_SEEK_CUR:
    base = f_tell((FIL *)pUserData);
    break;
  case DRWAV_SEEK_END:
    base = f_size((FIL *)pUserData);
    break;
  }
  if (f_lseek((FIL *)pUserData, base + offset) != FR_OK) {
    return DRWAV_FALSE;
  }
  return DRWAV_TRUE;
}

static drwav_bool32 drwav_on_tell_fatfs(void *pUserData, drwav_int64 *pCursor) {
  *pCursor = f_tell((FIL *)pUserData);
  return DRWAV_TRUE;
}

bool app_wav_stream_open(const char *path) {
  if (f_open(&wav_file, path, FA_READ) != FR_OK) {
    return false;
  }
  if (!drwav_init(&wav, drwav_on_read_fatfs, drwav_on_seek_fatfs,
                  drwav_on_tell_fatfs, &wav_file, NULL)) {
    f_close(&wav_file);
    return false;
  }
  if (wav.sampleRate != APP_WAV_SAMPLE_RATE ||
      (wav.channels != 1 && wav.channels != 2) ||
      wav.bitsPerSample != APP_WAV_BITS_PER_SAMPLE ||
      wav.translatedFormatTag != DR_WAVE_FORMAT_PCM) {
    drwav_uninit(&wav);
    f_close(&wav_file);
    return false;
  }
  return true;
}

void app_wav_stream_close(void) {
  drwav_uninit(&wav);
  f_close(&wav_file);
}

int app_wav_stream_read(uint16_t *buf, size_t len) {
  memset(buf, 0, len * APP_I2S_CHANNELS * sizeof(uint16_t));

  size_t read_len = drwav_read_pcm_frames_s16(&wav, len, wav_buf);
  if (f_error(&wav_file) != 0) {
    return -1;
  }

  if (wav.channels == 1) {
    for (size_t i = 0; i < read_len; ++i) {
      uint16_t sample = wav_buf[i];
      size_t out_idx = i * APP_I2S_CHANNELS;
      buf[out_idx + 0] = sample;
      buf[out_idx + 1] = sample;
    }
  } else {
    memcpy(buf, wav_buf, read_len * APP_I2S_CHANNELS * sizeof(uint16_t));
  }

  return read_len;
}

bool app_wav_stream_is_eof(void) { return wav.bytesRemaining == 0; }
