#pragma once

#include <stdbool.h>
#include <stdint.h>

#define APP_I2C_HANDLE hi2c1

bool app_wm8731_init(void);
bool app_wm8731_set_volume(int8_t volume);
