#pragma once

#include <stdbool.h>

#define APP_INPUT_INTERVAL_MS 50

typedef enum {
  APP_INPUT_EVENT_NONE = 0,
  APP_INPUT_EVENT_PLAY_PAUSE = 1 << 0,
  APP_INPUT_EVENT_NEXT_TRACK = 1 << 1,
  APP_INPUT_EVENT_VOLUME = 1 << 2,
} app_input_event_t;

app_input_event_t app_input_get_event(void);
