const std = @import("std");
const mx = @import("stm32cubemx");

const display = @import("display.zig");
const i2s = @import("i2s.zig");
const input = @import("input.zig");
const wav = @import("wav.zig");
const wm8731 = @import("wm8731.zig");

extern var Appli_state: mx.ApplicationTypeDef;

const Error = error{MountFailed};

const State = enum {
    stopped,
    paused,
    playing,
};

const volume_levels_db = [_]i8{ -60, -50, -40, -30, -20 };

var state: State = .stopped;
var track_index: usize = 0;
var volume_index: usize = 0;

pub fn entry() !void {
    while (Appli_state != mx.APPLICATION_READY) {
        mx.MX_USB_HOST_Process();
    }

    const usbh_path = std.mem.sliceTo(@as([*:0]const u8, @ptrCast(&mx.USBHPath)), 0);
    if (mx.f_mount(&mx.USBHFatFS, usbh_path.ptr, 1) != mx.FR_OK) return Error.MountFailed;
    try wav.init(usbh_path);
    try wm8731.init();
    try i2s.init();

    while (true) {
        switch (input.getEvent()) {
            .none => {},
            .play_pause => switch (state) {
                .stopped => playTrack(track_index),
                .paused => state = .playing,
                .playing => state = .paused,
            },
            .next_track => switch (state) {
                .stopped => playTrack(track_index),
                .paused, .playing => playTrack(track_index + 1),
            },
            .volume => volume_index = (volume_index + 1) % volume_levels_db.len,
        }

        if (state == .playing) {
            if (wav.isEof()) {
                playTrack(track_index + 1);
            } else if (i2s.reserve()) |buffer| {
                try wav.read(buffer);
                i2s.commit();
            }
        }

        wm8731.setVolume(volume_levels_db[volume_index]);
        display.setTrack(track_index + 1);

        mx.MX_USB_HOST_Process();
    }
}

fn playTrack(index: usize) void {
    var i = index;
    while (true) : (i += 1) {
        wav.open(i) catch |err| switch (err) {
            wav.Error.OutOfRange => {
                track_index = 0;
                state = .stopped;
                return;
            },
            else => continue,
        };
        track_index = i;
        state = .playing;
        return;
    }
}
