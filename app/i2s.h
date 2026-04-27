#pragma once

#include <stdbool.h>
#include <stdint.h>

#define APP_I2S_HANDLE hi2s1

#define APP_I2S_SAMPLES 2048
#define APP_I2S_CHANNELS 2

typedef enum {
  APP_I2S_STATE_STOPPED,
  APP_I2S_STATE_PAUSED,
  APP_I2S_STATE_PLAYING,
  APP_I2S_STATE_COUNT
} app_i2s_state_t;

typedef enum {
  APP_I2S_BUF_FIRST_HALF = 1 << 0,
  APP_I2S_BUF_SECOND_HALF = 1 << 1,
} app_i2s_buf_type_t;

app_i2s_state_t app_i2s_get_state(void);
void app_i2s_set_state(app_i2s_state_t state);
bool app_i2s_sync_state(void);
bool app_i2s_is_tx_buf_empty(app_i2s_buf_type_t buf_type);
void app_i2s_set_tx_buf_filled(app_i2s_buf_type_t buf_type);
uint16_t *app_i2s_get_tx_buf(app_i2s_buf_type_t buf_type);
