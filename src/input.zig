const mx = @import("stm32cubemx");

const Gpio = @import("Gpio.zig");

pub const Event = enum {
    none,
    play_pause,
    next_track,
    volume,
};

const play_pause_button: Gpio = .{ .port = mx.PLAY_PAUSE_GPIO_Port, .pin = mx.PLAY_PAUSE_Pin };
const next_track_button: Gpio = .{ .port = mx.NEXT_TRACK_GPIO_Port, .pin = mx.NEXT_TRACK_Pin };
const volume_button: Gpio = .{ .port = mx.VOLUME_GPIO_Port, .pin = mx.VOLUME_Pin };

var last_tick_ms: u32 = 0;
var play_pause_prev: Gpio.State = .high;
var next_track_prev: Gpio.State = .high;
var volume_prev: Gpio.State = .high;

pub fn getEvent() Event {
    const now_ms = mx.HAL_GetTick();
    if (now_ms -% last_tick_ms < 50) return .none;
    last_tick_ms = now_ms;

    if (isPressed(play_pause_button, &play_pause_prev)) return .play_pause;
    if (isPressed(next_track_button, &next_track_prev)) return .next_track;
    if (isPressed(volume_button, &volume_prev)) return .volume;
    return .none;
}

fn isPressed(button: Gpio, prev: *Gpio.State) bool {
    const state = button.read();
    defer prev.* = state;
    return state == .low and prev.* == .high;
}
