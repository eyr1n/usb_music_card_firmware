# usb_music_card_firmware

## Prerequisites

- Zig 0.16.0
- Meson
- Ninja

### Install Meson and Ninja

Using uv:

```sh
uv tool install meson
uv tool install ninja
```

Using pipx:

```sh
pipx install meson 
pipx install ninja
```

## Build

```sh
# Build Picolibc
meson setup --prefix / --cross-file cross.txt picolibc-build picolibc
meson compile -C picolibc-build
meson install -C picolibc-build --destdir ../picolibc-install

# Build .elf
zig build -Doptimize=ReleaseSmall
```
