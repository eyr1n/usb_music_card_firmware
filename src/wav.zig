const std = @import("std");
const mx = @import("stm32cubemx");

const i2s = @import("i2s.zig");

pub const Error = error{
    InitFailed,
    OutOfRange,
    OpenFailed,
    ReadFailed,
} || std.mem.Allocator.Error;

var file = std.mem.zeroes(mx.FIL);
var drwav = std.mem.zeroes(mx.drwav);

var fba_buffer: [1024]u8 = undefined;
var fba: std.heap.FixedBufferAllocator = .init(&fba_buffer);
var file_names: std.ArrayList([:0]const u8) = .empty;

pub fn init(path: [:0]const u8) Error!void {
    const allocator: std.mem.Allocator = fba.allocator();

    var dir: mx.DIR = undefined;
    if (mx.f_opendir(&dir, path.ptr) != mx.FR_OK) return Error.InitFailed;
    defer _ = mx.f_closedir(&dir);

    while (true) {
        var file_info: mx.FILINFO = undefined;
        if (mx.f_readdir(&dir, &file_info) != mx.FR_OK) return Error.InitFailed;
        const file_name = std.mem.sliceTo(&file_info.fname, 0);

        if (file_name.len == 0) break;
        if ((file_info.fattrib & mx.AM_DIR) != 0) continue;
        if (!std.mem.endsWith(u8, file_name, ".WAV")) continue;

        const file_name_owned = try allocator.dupeZ(u8, file_name);
        try file_names.append(allocator, file_name_owned);
    }

    std.mem.sortUnstable([:0]const u8, file_names.items, {}, lessThan);
}

pub fn open(index: usize) Error!void {
    if (index >= file_names.items.len) return Error.OutOfRange;

    _ = mx.drwav_uninit(&drwav);
    _ = mx.f_close(&file);

    if (mx.f_open(&file, file_names.items[index].ptr, mx.FA_READ) != mx.FR_OK) {
        return Error.OpenFailed;
    }

    if (mx.drwav_init(&drwav, onRead, onSeek, onTell, &file, null) != mx.DRWAV_TRUE) {
        _ = mx.f_close(&file);
        return Error.OpenFailed;
    }

    if (drwav.translatedFormatTag != mx.DR_WAVE_FORMAT_PCM or
        drwav.sampleRate != i2s.sample_rate or
        drwav.bitsPerSample != i2s.bits_per_sample or
        (drwav.channels != 1 and drwav.channels != 2))
    {
        _ = mx.drwav_uninit(&drwav);
        _ = mx.f_close(&file);
        return Error.OpenFailed;
    }
}

pub fn read(buffer: []u16) Error!void {
    const frames = @divExact(buffer.len, i2s.channels);
    @memset(buffer, 0);

    const frames_read: usize = @intCast(mx.drwav_read_pcm_frames_s16le(&drwav, frames, @ptrCast(buffer.ptr)));
    if (mx.f_error(&file) != 0) return Error.ReadFailed;

    if (drwav.channels == 1) {
        var i = frames_read;
        while (i > 0) {
            i -= 1;
            for (0..i2s.channels) |j| {
                buffer[i * i2s.channels + j] = buffer[i];
            }
        }
    }
}

pub fn isEof() bool {
    return drwav.bytesRemaining == 0;
}

fn lessThan(_: void, a: [:0]const u8, b: [:0]const u8) bool {
    return std.mem.lessThan(u8, a, b);
}

fn onRead(user_data: ?*anyopaque, buffer_out: ?*anyopaque, bytes_to_read: usize) callconv(.c) usize {
    const fp: *mx.FIL = @ptrCast(@alignCast(user_data));
    var bytes_read: usize = 0;
    if (mx.f_read(fp, buffer_out, bytes_to_read, &bytes_read) != mx.FR_OK) return 0;
    return bytes_read;
}

fn onSeek(user_data: ?*anyopaque, offset: c_int, origin: mx.drwav_seek_origin) callconv(.c) mx.drwav_bool32 {
    const fp: *mx.FIL = @ptrCast(@alignCast(user_data));
    const base: i64 = switch (origin) {
        mx.DRWAV_SEEK_SET => 0,
        mx.DRWAV_SEEK_CUR => @intCast(mx.f_tell(fp)),
        mx.DRWAV_SEEK_END => @intCast(mx.f_size(fp)),
        else => unreachable,
    };
    if (mx.f_lseek(fp, @intCast(base + offset)) != mx.FR_OK) return mx.DRWAV_FALSE;
    return mx.DRWAV_TRUE;
}

fn onTell(user_data: ?*anyopaque, cursor: [*c]mx.drwav_int64) callconv(.c) mx.drwav_bool32 {
    const fp: *mx.FIL = @ptrCast(@alignCast(user_data));
    cursor.* = @intCast(mx.f_tell(fp));
    return mx.DRWAV_TRUE;
}
