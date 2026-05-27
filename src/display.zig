const mx = @import("stm32cubemx");

const Gpio = @import("Gpio.zig");

const a: Gpio = .{ .port = mx.DIGIT_A_GPIO_Port, .pin = mx.DIGIT_A_Pin };
const b: Gpio = .{ .port = mx.DIGIT_B_GPIO_Port, .pin = mx.DIGIT_B_Pin };
const c: Gpio = .{ .port = mx.DIGIT_C_GPIO_Port, .pin = mx.DIGIT_C_Pin };
const d: Gpio = .{ .port = mx.DIGIT_D_GPIO_Port, .pin = mx.DIGIT_D_Pin };
const e: Gpio = .{ .port = mx.DIGIT_E_GPIO_Port, .pin = mx.DIGIT_E_Pin };
const f: Gpio = .{ .port = mx.DIGIT_F_GPIO_Port, .pin = mx.DIGIT_F_Pin };
const g: Gpio = .{ .port = mx.DIGIT_G_GPIO_Port, .pin = mx.DIGIT_G_Pin };
const dp: Gpio = .{ .port = mx.DIGIT_DP_GPIO_Port, .pin = mx.DIGIT_DP_Pin };

var track_prev: ?usize = null;

pub fn setTrack(track: usize) void {
    if (track == track_prev) return;

    switch (track % 10) {
        0 => {
            a.write(.high);
            b.write(.high);
            c.write(.high);
            d.write(.high);
            e.write(.high);
            f.write(.high);
            g.write(.low);
        },
        1 => {
            a.write(.low);
            b.write(.high);
            c.write(.high);
            d.write(.low);
            e.write(.low);
            f.write(.low);
            g.write(.low);
        },
        2 => {
            a.write(.high);
            b.write(.high);
            c.write(.low);
            d.write(.high);
            e.write(.high);
            f.write(.low);
            g.write(.high);
        },
        3 => {
            a.write(.high);
            b.write(.high);
            c.write(.high);
            d.write(.high);
            e.write(.low);
            f.write(.low);
            g.write(.high);
        },
        4 => {
            a.write(.low);
            b.write(.high);
            c.write(.high);
            d.write(.low);
            e.write(.low);
            f.write(.high);
            g.write(.high);
        },
        5 => {
            a.write(.high);
            b.write(.low);
            c.write(.high);
            d.write(.high);
            e.write(.low);
            f.write(.high);
            g.write(.high);
        },
        6 => {
            a.write(.high);
            b.write(.low);
            c.write(.high);
            d.write(.high);
            e.write(.high);
            f.write(.high);
            g.write(.high);
        },
        7 => {
            a.write(.high);
            b.write(.high);
            c.write(.high);
            d.write(.low);
            e.write(.low);
            f.write(.low);
            g.write(.low);
        },
        8 => {
            a.write(.high);
            b.write(.high);
            c.write(.high);
            d.write(.high);
            e.write(.high);
            f.write(.high);
            g.write(.high);
        },
        9 => {
            a.write(.high);
            b.write(.high);
            c.write(.high);
            d.write(.high);
            e.write(.low);
            f.write(.high);
            g.write(.high);
        },
        else => unreachable,
    }

    dp.write(if (track >= 10) .high else .low);
    track_prev = track;
}
