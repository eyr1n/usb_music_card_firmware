#pragma once

#include <stdbool.h>
#include <stdint.h>

#define APP_WAV_SAMPLE_RATE 44100
#define APP_WAV_BITS_PER_SAMPLE 16

bool app_wav_stream_open(const char *path);
void app_wav_stream_close(void);
int app_wav_stream_read(uint16_t *buf, size_t len);
bool app_wav_stream_is_eof(void);
