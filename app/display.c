#include <stdint.h>

#include "display.h"
#include "main.h"

static uint32_t digit_prev = 0;

void app_display_set_digit(uint32_t digit) {
  if (digit == digit_prev) {
    return;
  }

  switch (digit % 10) {
  case 0:
    HAL_GPIO_WritePin(DIGIT_A_GPIO_Port, DIGIT_A_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_B_GPIO_Port, DIGIT_B_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_C_GPIO_Port, DIGIT_C_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_D_GPIO_Port, DIGIT_D_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_E_GPIO_Port, DIGIT_E_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_F_GPIO_Port, DIGIT_F_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_G_GPIO_Port, DIGIT_G_Pin, GPIO_PIN_RESET);
    break;
  case 1:
    HAL_GPIO_WritePin(DIGIT_A_GPIO_Port, DIGIT_A_Pin, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(DIGIT_B_GPIO_Port, DIGIT_B_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_C_GPIO_Port, DIGIT_C_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_D_GPIO_Port, DIGIT_D_Pin, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(DIGIT_E_GPIO_Port, DIGIT_E_Pin, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(DIGIT_F_GPIO_Port, DIGIT_F_Pin, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(DIGIT_G_GPIO_Port, DIGIT_G_Pin, GPIO_PIN_RESET);
    break;
  case 2:
    HAL_GPIO_WritePin(DIGIT_A_GPIO_Port, DIGIT_A_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_B_GPIO_Port, DIGIT_B_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_C_GPIO_Port, DIGIT_C_Pin, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(DIGIT_D_GPIO_Port, DIGIT_D_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_E_GPIO_Port, DIGIT_E_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_F_GPIO_Port, DIGIT_F_Pin, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(DIGIT_G_GPIO_Port, DIGIT_G_Pin, GPIO_PIN_SET);
    break;
  case 3:
    HAL_GPIO_WritePin(DIGIT_A_GPIO_Port, DIGIT_A_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_B_GPIO_Port, DIGIT_B_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_C_GPIO_Port, DIGIT_C_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_D_GPIO_Port, DIGIT_D_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_E_GPIO_Port, DIGIT_E_Pin, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(DIGIT_F_GPIO_Port, DIGIT_F_Pin, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(DIGIT_G_GPIO_Port, DIGIT_G_Pin, GPIO_PIN_SET);
    break;
  case 4:
    HAL_GPIO_WritePin(DIGIT_A_GPIO_Port, DIGIT_A_Pin, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(DIGIT_B_GPIO_Port, DIGIT_B_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_C_GPIO_Port, DIGIT_C_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_D_GPIO_Port, DIGIT_D_Pin, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(DIGIT_E_GPIO_Port, DIGIT_E_Pin, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(DIGIT_F_GPIO_Port, DIGIT_F_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_G_GPIO_Port, DIGIT_G_Pin, GPIO_PIN_SET);
    break;
  case 5:
    HAL_GPIO_WritePin(DIGIT_A_GPIO_Port, DIGIT_A_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_B_GPIO_Port, DIGIT_B_Pin, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(DIGIT_C_GPIO_Port, DIGIT_C_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_D_GPIO_Port, DIGIT_D_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_E_GPIO_Port, DIGIT_E_Pin, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(DIGIT_F_GPIO_Port, DIGIT_F_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_G_GPIO_Port, DIGIT_G_Pin, GPIO_PIN_SET);
    break;
  case 6:
    HAL_GPIO_WritePin(DIGIT_A_GPIO_Port, DIGIT_A_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_B_GPIO_Port, DIGIT_B_Pin, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(DIGIT_C_GPIO_Port, DIGIT_C_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_D_GPIO_Port, DIGIT_D_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_E_GPIO_Port, DIGIT_E_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_F_GPIO_Port, DIGIT_F_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_G_GPIO_Port, DIGIT_G_Pin, GPIO_PIN_SET);
    break;
  case 7:
    HAL_GPIO_WritePin(DIGIT_A_GPIO_Port, DIGIT_A_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_B_GPIO_Port, DIGIT_B_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_C_GPIO_Port, DIGIT_C_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_D_GPIO_Port, DIGIT_D_Pin, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(DIGIT_E_GPIO_Port, DIGIT_E_Pin, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(DIGIT_F_GPIO_Port, DIGIT_F_Pin, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(DIGIT_G_GPIO_Port, DIGIT_G_Pin, GPIO_PIN_RESET);
    break;
  case 8:
    HAL_GPIO_WritePin(DIGIT_A_GPIO_Port, DIGIT_A_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_B_GPIO_Port, DIGIT_B_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_C_GPIO_Port, DIGIT_C_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_D_GPIO_Port, DIGIT_D_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_E_GPIO_Port, DIGIT_E_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_F_GPIO_Port, DIGIT_F_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_G_GPIO_Port, DIGIT_G_Pin, GPIO_PIN_SET);
    break;
  case 9:
    HAL_GPIO_WritePin(DIGIT_A_GPIO_Port, DIGIT_A_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_B_GPIO_Port, DIGIT_B_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_C_GPIO_Port, DIGIT_C_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_D_GPIO_Port, DIGIT_D_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_E_GPIO_Port, DIGIT_E_Pin, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(DIGIT_F_GPIO_Port, DIGIT_F_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(DIGIT_G_GPIO_Port, DIGIT_G_Pin, GPIO_PIN_SET);
    break;
  }
  HAL_GPIO_WritePin(DIGIT_DP_GPIO_Port, DIGIT_DP_Pin,
                    digit >= 10 ? GPIO_PIN_SET : GPIO_PIN_RESET);

  digit_prev = digit;
}
