const st = @import("stm32cubemx");

extern var hi2s1: st.I2S_HandleTypeDef;

pub const State = enum {
    stopped,
    paused,
    playing,
};

pub const BufferHalf = enum(u8) {
    first = 1 << 0,
    second = 1 << 1,
};

pub const Error = error{
    StartFailed,
    ResumeFailed,
    PauseFailed,
    StopFailed,
};

pub const samples: usize = 2048;
pub const channels: usize = 2;

var tx_buffer = [_]u16{0} ** (samples * channels * 2);
var tx_half_cplt_flags: u8 = 0;
var state = State.stopped;

pub fn getState() State {
    return state;
}

pub fn setState(next: State) Error!void {
    switch (state) {
        .stopped => switch (next) {
            .playing => try startDma(),
            else => {},
        },
        .paused => switch (next) {
            .stopped => try stopDma(),
            .playing => try resumeDma(),
            else => {},
        },
        .playing => switch (next) {
            .stopped => try stopDma(),
            .paused => try pauseDma(),
            else => {},
        },
    }

    state = next;
}

pub fn isBufferEmpty(half: BufferHalf) bool {
    return (@atomicLoad(u8, &tx_half_cplt_flags, .acquire) & @intFromEnum(half)) == 0;
}

pub fn markBufferFilled(half: BufferHalf) void {
    _ = @atomicRmw(u8, &tx_half_cplt_flags, .Or, @intFromEnum(half), .acq_rel);
}

pub fn getBuffer(half: BufferHalf) []u16 {
    return switch (half) {
        .first => tx_buffer[0 .. samples * channels],
        .second => tx_buffer[samples * channels ..],
    };
}

fn startDma() Error!void {
    if (st.HAL_I2S_Transmit_DMA(&hi2s1, &tx_buffer, tx_buffer.len) != st.HAL_OK) {
        return Error.StartFailed;
    }
}

fn resumeDma() Error!void {
    if (st.HAL_I2S_DMAResume(&hi2s1) != st.HAL_OK) {
        return Error.ResumeFailed;
    }
}

fn pauseDma() Error!void {
    if (st.HAL_I2S_DMAPause(&hi2s1) != st.HAL_OK) {
        return Error.PauseFailed;
    }
}

fn stopDma() Error!void {
    if (st.HAL_I2S_DMAStop(&hi2s1) != st.HAL_OK) {
        return Error.StopFailed;
    }
    @atomicStore(u8, &tx_half_cplt_flags, 0, .release);
}

export fn HAL_I2S_TxHalfCpltCallback(hi2s: [*c]st.I2S_HandleTypeDef) void {
    if (hi2s.*.Instance == hi2s1.Instance) {
        _ = @atomicRmw(u8, &tx_half_cplt_flags, .And, ~@intFromEnum(BufferHalf.first), .acq_rel);
    }
}

export fn HAL_I2S_TxCpltCallback(hi2s: [*c]st.I2S_HandleTypeDef) void {
    if (hi2s.*.Instance == hi2s1.Instance) {
        _ = @atomicRmw(u8, &tx_half_cplt_flags, .And, ~@intFromEnum(BufferHalf.second), .acq_rel);
    }
}
