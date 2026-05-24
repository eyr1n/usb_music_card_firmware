const std = @import("std");
const st = @import("stm32cubemx");

const File = @import("fatfs.zig").File;

pub const Error = error{InitFailed};

handle: st.drwav,

pub fn init(file: *File) Error!@This() {
    var self: @This() = undefined;
    return if (st.drwav_init(&self.handle, onRead, onSeek, onTell, @ptrCast(file), null) == st.DRWAV_TRUE) self else Error.InitFailed;
}

pub fn deinit(self: *@This()) void {
    _ = st.drwav_uninit(&self.handle);
}

pub fn readPcmFrames(self: *@This(), comptime T: type, ptr: [*]T, frames: usize, endian: std.builtin.Endian) usize {
    return @intCast(switch (T) {
        i16 => switch (endian) {
            .big => st.drwav_read_pcm_frames_s16be(&self.handle, frames, ptr),
            .little => st.drwav_read_pcm_frames_s16le(&self.handle, frames, ptr),
        },
        else => @compileError("Unsupported type: " ++ @typeName(T)),
    });
}

fn onRead(user_data: ?*anyopaque, buffer_out: ?*anyopaque, bytes_to_read: usize) callconv(.c) usize {
    const file: *File = @ptrCast(@alignCast(user_data));
    const buffer: [*]u8 = @ptrCast(buffer_out);
    return file.read(buffer[0..bytes_to_read]) catch 0;
}

fn onSeek(user_data: ?*anyopaque, offset: c_int, origin: st.drwav_seek_origin) callconv(.c) st.drwav_bool32 {
    const file: *File = @ptrCast(@alignCast(user_data));
    const base: isize = switch (origin) {
        st.DRWAV_SEEK_SET => 0,
        st.DRWAV_SEEK_CUR => @intCast(file.tell()),
        st.DRWAV_SEEK_END => @intCast(file.size()),
        else => unreachable,
    };
    file.seek(@intCast(base + @as(isize, offset))) catch return st.DRWAV_FALSE;
    return st.DRWAV_TRUE;
}

fn onTell(user_data: ?*anyopaque, cursor: [*c]st.drwav_int64) callconv(.c) st.drwav_bool32 {
    const file: *File = @ptrCast(@alignCast(user_data));
    cursor.* = @intCast(file.tell());
    return st.DRWAV_TRUE;
}
