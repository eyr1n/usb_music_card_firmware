const std = @import("std");
const mx = @import("stm32cubemx");

extern var hi2s1: mx.I2S_HandleTypeDef;

pub const Error = error{InitFailed};

pub const sample_rate: u32 = 44100;
pub const bits_per_sample: u16 = 16;
pub const channels: usize = 2;

const frames_per_buffer: usize = 1024;
const queue_depth: usize = 8;

var dma_buffer = std.mem.zeroes([frames_per_buffer * channels * 2]u16);
var queue_buffer = std.mem.zeroes([queue_depth + 1][frames_per_buffer * channels]u16);
var read_index: usize = 0;
var write_index: usize = 0;
var flush_queue: bool = false;
var pause_queue: bool = false;

pub fn init() Error!void {
    if (mx.HAL_I2S_Transmit_DMA(&hi2s1, &dma_buffer, @intCast(dma_buffer.len)) != mx.HAL_OK) {
        return Error.InitFailed;
    }
}

pub fn reserveQueue() ?[]u16 {
    if (@atomicLoad(bool, &flush_queue, .acquire)) return null;
    const read = @atomicLoad(usize, &read_index, .acquire);
    const write = @atomicLoad(usize, &write_index, .acquire);
    if ((write + 1) % queue_buffer.len == read) return null;
    return &queue_buffer[write];
}

pub fn commitQueue() void {
    const write = @atomicLoad(usize, &write_index, .acquire);
    @atomicStore(usize, &write_index, (write + 1) % queue_buffer.len, .release);
}

pub fn flushQueue() void {
    if (isQueueEmpty()) return;
    @atomicStore(bool, &flush_queue, true, .release);
}

pub fn pauseQueue() void {
    @atomicStore(bool, &pause_queue, true, .release);
}

pub fn resumeQueue() void {
    @atomicStore(bool, &pause_queue, false, .release);
}

pub fn isQueueEmpty() bool {
    const read = @atomicLoad(usize, &read_index, .acquire);
    const write = @atomicLoad(usize, &write_index, .acquire);
    return read == write;
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
    if (@atomicRmw(bool, &flush_queue, .Xchg, false, .acq_rel)) {
        const write = @atomicLoad(usize, &write_index, .acquire);
        @atomicStore(usize, &read_index, write, .release);
        @memset(buffer, 0);
        return;
    }

    if (@atomicLoad(bool, &pause_queue, .acquire)) {
        @memset(buffer, 0);
        return;
    }

    const read = @atomicLoad(usize, &read_index, .acquire);
    const write = @atomicLoad(usize, &write_index, .acquire);
    if (read == write) {
        @memset(buffer, 0);
        return;
    }

    @memcpy(buffer, queue_buffer[read][0..]);
    @atomicStore(usize, &read_index, (read + 1) % queue_buffer.len, .release);
}
