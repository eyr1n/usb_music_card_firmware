const st = @import("stm32cubemx");

const i2s = @import("i2s.zig");

const DrWav = @import("DrWav.zig");
const File = @import("fatfs.zig").File;

pub const Error = error{InvalidFormat} || File.Error || DrWav.Error;

const sample_rate: u32 = 44100;
const bits_per_sample: u16 = 16;

var file: File = undefined;
var wav: DrWav = undefined;

pub fn open(path: [:0]const u8) Error!void {
    file = try File.open(path, st.FA_READ);
    errdefer file.close();
    wav = try DrWav.init(&file);
    errdefer wav.deinit();

    if (wav.handle.sampleRate != sample_rate or
        (wav.handle.channels != 1 and wav.handle.channels != 2) or
        wav.handle.bitsPerSample != bits_per_sample or
        wav.handle.translatedFormatTag != st.DR_WAVE_FORMAT_PCM)
    {
        return Error.InvalidFormat;
    }
}

pub fn close() void {
    wav.deinit();
    file.close();
}

pub fn read(buffer: []u16) Error!void {
    const frames = @divExact(buffer.len, i2s.channels);
    @memset(buffer, 0);

    const read_frames = wav.readPcmFrames(i16, @ptrCast(buffer.ptr), frames, .little);
    if (file.errorCode() != 0) return Error.ReadFailed;

    if (wav.handle.channels == 1) {
        var i: usize = read_frames;
        while (i > 0) {
            i -= 1;
            for (0..i2s.channels) |j| {
                buffer[i * i2s.channels + j] = buffer[i];
            }
        }
    }
}

pub fn isEof() bool {
    return wav.handle.bytesRemaining == 0;
}
