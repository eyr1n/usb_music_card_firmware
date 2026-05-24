const st = @import("stm32cubemx");

const Gpio = @import("Gpio.zig");

pub const Event = enum {
    none,
    play_pause,
    next_track,
    volume,
};

const interval_ms: u32 = 50;

const play_pause_button: Gpio = .{ .port = st.PLAY_PAUSE_GPIO_Port, .pin = st.PLAY_PAUSE_Pin };
const next_track_button: Gpio = .{ .port = st.NEXT_TRACK_GPIO_Port, .pin = st.NEXT_TRACK_Pin };
const volume_button: Gpio = .{ .port = st.VOLUME_GPIO_Port, .pin = st.VOLUME_Pin };

var last_tick_ms: u32 = 0;
var pending_event: Event = .none;

var play_pause_state_prev: Gpio.State = .high;
var next_track_state_prev: Gpio.State = .high;
var volume_state_prev: Gpio.State = .high;

pub fn getEvent() Event {
    const now_ms = st.HAL_GetTick();
    if (now_ms -% last_tick_ms >= interval_ms) {
        last_tick_ms = now_ms;
        processPlayPauseButton();
        processNextTrackButton();
        processVolumeButton();
    }

    const event = pending_event;
    pending_event = .none;
    return event;
}

fn processPlayPauseButton() void {
    const state = play_pause_button.read();
    if (state != play_pause_state_prev) {
        if (state == .low) pending_event = .play_pause;
        play_pause_state_prev = state;
    }
}

fn processNextTrackButton() void {
    const state = next_track_button.read();
    if (state != next_track_state_prev) {
        if (state == .low) pending_event = .next_track;
        next_track_state_prev = state;
    }
}

fn processVolumeButton() void {
    const state = volume_button.read();
    if (state != volume_state_prev) {
        if (state == .low) pending_event = .volume;
        volume_state_prev = state;
    }
}
