const std = @import("std");
const st = @import("stm32cubemx");

const display = @import("display.zig");
const fatfs = @import("fatfs.zig");
const i2s = @import("i2s.zig");
const input = @import("input.zig");
const wav_stream = @import("wav_stream.zig");
const wm8731 = @import("wm8731.zig");

const WavList = @import("WavList.zig");

extern var Appli_state: st.ApplicationTypeDef;

const Error = error{TrackNotFound};

const volume_levels_db = [_]i8{ -60, -50, -40, -30, -20 };

var wav_list_buffer: [1024]u8 = undefined;
var track_index: usize = 0;
var volume_level_index: usize = 0;

pub fn entry() !void {
    while (Appli_state != st.APPLICATION_READY) {
        st.MX_USB_HOST_Process();
    }

    const usbh_path = std.mem.sliceTo(@as([*:0]const u8, @ptrCast(&st.USBHPath)), 0);

    try fatfs.mount(&st.USBHFatFS, usbh_path, true);

    var fba: std.heap.FixedBufferAllocator = .init(&wav_list_buffer);
    var wav_list = try WavList.init(fba.allocator(), usbh_path);

    try wm8731.init();

    while (true) {
        switch (input.getEvent()) {
            .play_pause => switch (i2s.getState()) {
                .stopped => try startTrack(&wav_list, track_index),
                .paused => try i2s.setState(.playing),
                .playing => try i2s.setState(.paused),
            },
            .next_track => switch (i2s.getState()) {
                .stopped => try startTrack(&wav_list, track_index),
                .paused, .playing => advanceTrack(&wav_list) catch continue,
            },
            .volume => volume_level_index = (volume_level_index + 1) % volume_levels_db.len,
            .none => {},
        }

        if (i2s.getState() == .playing) {
            if (wav_stream.isEof() and i2s.isBufferEmpty(.first) and i2s.isBufferEmpty(.second)) {
                advanceTrack(&wav_list) catch continue;
            } else if (!wav_stream.isEof()) {
                if (i2s.isBufferEmpty(.first)) try fillBuffer(.first);
                if (i2s.isBufferEmpty(.second)) try fillBuffer(.second);
            }
        }

        wm8731.setVolume(volume_levels_db[volume_level_index]) catch {};
        display.setDigit(track_index + 1);

        st.MX_USB_HOST_Process();
    }
}

fn startTrack(wav_list: *WavList, index: usize) !void {
    try openWavStream(wav_list, index);
    try fillBuffer(.first);
    try fillBuffer(.second);
    try i2s.setState(.playing);
}

fn advanceTrack(wav_list: *WavList) !void {
    try i2s.setState(.stopped);
    wav_stream.close();
    try startTrack(wav_list, track_index + 1);
}

fn openWavStream(wav_list: *WavList, index: usize) Error!void {
    for (wav_list.names()[index..], index..) |path, i| {
        wav_stream.open(path) catch continue;
        track_index = i;
        return;
    }
    track_index = 0;
    return Error.TrackNotFound;
}

fn fillBuffer(half: i2s.BufferHalf) !void {
    try wav_stream.read(i2s.getBuffer(half));
    i2s.markBufferFilled(half);
}
