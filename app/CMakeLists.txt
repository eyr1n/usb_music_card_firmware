add_library(app OBJECT
  main.c
  display.c
  i2s.c
  input.c
  wav_list.c
  wav_stream.c
  wm8731.c
)

target_link_libraries(app PRIVATE stm32cubemx)

target_compile_features(app PRIVATE c_std_11)
