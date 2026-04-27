#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "ff.h"

#include "wav_list.h"

#if _USE_LFN != 0
#error "LFN is not supported."
#endif

static char wav_list[APP_WAV_LIST_MAX_LEN][APP_WAV_LIST_MAX_NAME_LEN];
static char *wav_list_sorted[APP_WAV_LIST_MAX_LEN];
static uint16_t wav_list_len = 0U;

static bool ends_with(const char *str, const char *suffix) {
  size_t str_len = strlen(str);
  size_t suffix_len = strlen(suffix);
  if (str_len < suffix_len) {
    return false;
  }
  return strcmp(&str[str_len - suffix_len], suffix) == 0;
}

static int compare_str(const void *a, const void *b) {
  return strcmp(*(const char **)a, *(const char **)b);
}

bool app_wav_list_init(const char *path) {
  DIR dir;
  if (f_opendir(&dir, path) != FR_OK) {
    return false;
  }

  while (true) {
    if (wav_list_len >= APP_WAV_LIST_MAX_LEN) {
      break;
    }

    FILINFO file_info;
    if (f_readdir(&dir, &file_info) != FR_OK) {
      f_closedir(&dir);
      return false;
    }
    if (file_info.fname[0] == '\0') {
      break;
    }
    if ((file_info.fattrib & AM_DIR) != 0) {
      continue;
    }
    if (!ends_with(file_info.fname, ".WAV")) {
      continue;
    }
    memcpy(wav_list[wav_list_len], file_info.fname,
           sizeof(wav_list[wav_list_len]));
    wav_list_sorted[wav_list_len] = wav_list[wav_list_len];
    ++wav_list_len;
  }

  f_closedir(&dir);

  qsort(wav_list_sorted, wav_list_len, sizeof(wav_list_sorted[0]), compare_str);
  return true;
}

size_t app_wav_list_get_len(void) { return wav_list_len; }

const char *app_wav_list_get_name_by_index(size_t index) {
  if (index >= wav_list_len) {
    return NULL;
  }
  return wav_list_sorted[index];
}
