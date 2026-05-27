const mx = @import("stm32cubemx");

extern var hi2s1: mx.I2S_HandleTypeDef;

pub const Error = error{InitFailed};

pub const sample_rate: u32 = 44100;
pub const bits_per_sample: u16 = 16;
pub const channels: usize = 2;
pub const frames_per_buffer: usize = 2048;

var dma_buffer = [_]u16{0} ** (frames_per_buffer * channels * 2);
var queue_buffer = [_]u16{0} ** (frames_per_buffer * channels);
var queued: bool = false;

pub fn init() Error!void {
    if (mx.HAL_I2S_Transmit_DMA(&hi2s1, &dma_buffer, @intCast(dma_buffer.len)) != mx.HAL_OK) {
        return Error.InitFailed;
    }
}

pub fn reserve() ?[]u16 {
    if (@atomicLoad(bool, &queued, .acquire)) return null;
    return &queue_buffer;
}

pub fn commit() void {
    @atomicStore(bool, &queued, true, .release);
}

export fn HAL_I2S_TxHalfCpltCallback(hi2s: [*c]mx.I2S_HandleTypeDef) void {
    if (hi2s.*.Instance == hi2s1.Instance) {
        fillDmaBuffer(dma_buffer[0..@divExact(dma_buffer.len, 2)]);
    }
}

export fn HAL_I2S_TxCpltCallback(hi2s: [*c]mx.I2S_HandleTypeDef) void {
    if (hi2s.*.Instance == hi2s1.Instance) {
        fillDmaBuffer(dma_buffer[@divExact(dma_buffer.len, 2)..]);
    }
}

fn fillDmaBuffer(buffer: []u16) void {
    if (@atomicLoad(bool, &queued, .acquire)) {
        @memcpy(buffer, &queue_buffer);
        @atomicStore(bool, &queued, false, .release);
    } else {
        @memset(buffer, 0);
    }
}
