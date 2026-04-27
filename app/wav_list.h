#pragma once

#include <stdbool.h>
#include <stddef.h>

#define APP_WAV_LIST_MAX_LEN 64
#define APP_WAV_LIST_MAX_NAME_LEN 13 // no LFN support

bool app_wav_list_init(const char *path);
size_t app_wav_list_get_len(void);
const char *app_wav_list_get_name_by_index(size_t index);
