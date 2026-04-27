#include "stm32f4xx_hal.h"

#include "wm8731.h"

extern I2C_HandleTypeDef APP_I2C_HANDLE;

static int8_t volume_prev = 0;

static bool wm8731_write(uint8_t address, uint16_t data) {
  uint8_t payload[] = {(address << 1) | ((data >> 8) & 0x01), data & 0xFF};
  return HAL_I2C_Master_Transmit(&APP_I2C_HANDLE, 0x1A << 1, payload,
                                 sizeof(payload), 100) == HAL_OK;
}

bool app_wm8731_init(void) {
  // R15 Reset Register
  if (!wm8731_write(0x0F, 0x000)) {
    return false;
  }
  // R6 Power Down Control
  if (!wm8731_write(0x06, 0x077)) {
    return false;
  }
  // R4 Analogue Audio Path Control
  if (!wm8731_write(0x04, 0x010)) {
    return false;
  }
  // R5 Digital Audio Path Control
  if (!wm8731_write(0x05, 0x000)) {
    return false;
  }
  // R7 Digital Audio Interface Format
  if (!wm8731_write(0x07, 0x002)) {
    return false;
  }
  // R8 Sampling Control
  if (!wm8731_write(0x08, 0x020)) {
    return false;
  }
  // R9 Active Control
  if (!wm8731_write(0x09, 0x001)) {
    return false;
  }
  // R6 Power Down Control
  if (!wm8731_write(0x06, 0x067)) {
    return false;
  }
  return true;
}

bool app_wm8731_set_volume(int8_t volume) {
  if (volume == volume_prev) {
    return true;
  }
  if (!wm8731_write(0x02, volume + 121)) {
    return false;
  }
  if (!wm8731_write(0x03, volume + 121)) {
    return false;
  }
  volume_prev = volume;
  return true;
}
