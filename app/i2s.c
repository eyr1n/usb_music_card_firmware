#include "stm32f4xx_hal.h"

#include "i2s.h"

extern I2S_HandleTypeDef APP_I2S_HANDLE;

static app_i2s_state_t state_next = APP_I2S_STATE_STOPPED;
static app_i2s_state_t state_prev = APP_I2S_STATE_STOPPED;
static volatile uint32_t tx_half_cplt_flags = 0;
static volatile bool error_occurred = false;
static uint16_t tx_buf[APP_I2S_SAMPLES * APP_I2S_CHANNELS * 2];

static void transition_start_dma(void) {
  if (HAL_I2S_Transmit_DMA(&APP_I2S_HANDLE, tx_buf,
                           sizeof(tx_buf) / sizeof(tx_buf[0])) != HAL_OK) {
    error_occurred = true;
  }
}

static void transition_resume_dma(void) {
  if (HAL_I2S_DMAResume(&APP_I2S_HANDLE) != HAL_OK) {
    error_occurred = true;
  }
}

static void transition_pause_dma(void) {
  if (HAL_I2S_DMAPause(&APP_I2S_HANDLE) != HAL_OK) {
    error_occurred = true;
  }
}

static void transition_stop_dma(void) {
  if (HAL_I2S_DMAStop(&APP_I2S_HANDLE) != HAL_OK) {
    error_occurred = true;
  }
  tx_half_cplt_flags = 0;
}

static void (*const TRANSITION_TABLE[APP_I2S_STATE_COUNT][APP_I2S_STATE_COUNT])(
    void) = {
    [APP_I2S_STATE_STOPPED] =
        {
            [APP_I2S_STATE_PLAYING] = transition_start_dma,
        },
    [APP_I2S_STATE_PAUSED] =
        {
            [APP_I2S_STATE_STOPPED] = transition_stop_dma,
            [APP_I2S_STATE_PLAYING] = transition_resume_dma,
        },
    [APP_I2S_STATE_PLAYING] =
        {
            [APP_I2S_STATE_STOPPED] = transition_stop_dma,
            [APP_I2S_STATE_PAUSED] = transition_pause_dma,
        },
};

app_i2s_state_t app_i2s_get_state(void) { return state_next; }

void app_i2s_set_state(app_i2s_state_t state) { state_next = state; }

bool app_i2s_sync_state(void) {
  if (state_next == state_prev) {
    return true;
  }
  void (*fn)(void) = TRANSITION_TABLE[state_prev][state_next];
  if (fn) {
    fn();
  }
  if (error_occurred) {
    return false;
  }
  state_prev = state_next;
  return true;
}

bool app_i2s_is_tx_buf_empty(app_i2s_buf_type_t buf_type) {
  return (tx_half_cplt_flags & buf_type) == 0;
}

void app_i2s_set_tx_buf_filled(app_i2s_buf_type_t buf_type) {
  tx_half_cplt_flags |= buf_type;
}

uint16_t *app_i2s_get_tx_buf(app_i2s_buf_type_t buf_type) {
  switch (buf_type) {
  case APP_I2S_BUF_FIRST_HALF:
    return tx_buf;
  case APP_I2S_BUF_SECOND_HALF:
    return &tx_buf[APP_I2S_SAMPLES * APP_I2S_CHANNELS];
  }
  return NULL;
}

void HAL_I2S_TxHalfCpltCallback(I2S_HandleTypeDef *hi2s) {
  if (hi2s->Instance == APP_I2S_HANDLE.Instance) {
    tx_half_cplt_flags &= ~APP_I2S_BUF_FIRST_HALF;
  }
}

void HAL_I2S_TxCpltCallback(I2S_HandleTypeDef *hi2s) {
  if (hi2s->Instance == APP_I2S_HANDLE.Instance) {
    tx_half_cplt_flags &= ~APP_I2S_BUF_SECOND_HALF;
  }
}

void HAL_I2S_ErrorCallback(I2S_HandleTypeDef *hi2s) {
  if (hi2s->Instance == APP_I2S_HANDLE.Instance) {
    error_occurred = true;
  }
}
