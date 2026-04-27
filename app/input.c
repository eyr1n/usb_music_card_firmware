#include <stdbool.h>
#include <stdint.h>

#include "stm32f4xx_hal.h"

#include "input.h"
#include "main.h"

static app_input_event_t pending_event = APP_INPUT_EVENT_NONE;
static uint32_t last_tick_ms = 0;

static void process_play_pause_button(void) {
  static GPIO_PinState state_prev = GPIO_PIN_SET;
  GPIO_PinState state = HAL_GPIO_ReadPin(PLAY_PAUSE_GPIO_Port, PLAY_PAUSE_Pin);
  if (state != state_prev) {
    if (state == GPIO_PIN_RESET) {
      pending_event = APP_INPUT_EVENT_PLAY_PAUSE;
    }
    state_prev = state;
  }
}

static void process_next_track_button(void) {
  static GPIO_PinState state_prev = GPIO_PIN_SET;
  GPIO_PinState state = HAL_GPIO_ReadPin(NEXT_TRACK_GPIO_Port, NEXT_TRACK_Pin);
  if (state != state_prev) {
    if (state == GPIO_PIN_RESET) {
      pending_event = APP_INPUT_EVENT_NEXT_TRACK;
    }
    state_prev = state;
  }
}

static void process_volume_button(void) {
  static GPIO_PinState state_prev = GPIO_PIN_SET;
  GPIO_PinState state = HAL_GPIO_ReadPin(VOLUME_GPIO_Port, VOLUME_Pin);
  if (state != state_prev) {
    if (state == GPIO_PIN_RESET) {
      pending_event = APP_INPUT_EVENT_VOLUME;
    }
    state_prev = state;
  }
}

app_input_event_t app_input_get_event(void) {
  uint32_t now_ms = HAL_GetTick();
  if ((uint32_t)(now_ms - last_tick_ms) >= APP_INPUT_INTERVAL_MS) {
    last_tick_ms = now_ms;
    process_play_pause_button();
    process_next_track_button();
    process_volume_button();
  }

  app_input_event_t event = pending_event;
  pending_event = APP_INPUT_EVENT_NONE;
  return event;
}
