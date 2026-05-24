const st = @import("stm32cubemx");

const Gpio = @import("Gpio.zig");

const a: Gpio = .{ .port = st.DIGIT_A_GPIO_Port, .pin = st.DIGIT_A_Pin };
const b: Gpio = .{ .port = st.DIGIT_B_GPIO_Port, .pin = st.DIGIT_B_Pin };
const c: Gpio = .{ .port = st.DIGIT_C_GPIO_Port, .pin = st.DIGIT_C_Pin };
const d: Gpio = .{ .port = st.DIGIT_D_GPIO_Port, .pin = st.DIGIT_D_Pin };
const e: Gpio = .{ .port = st.DIGIT_E_GPIO_Port, .pin = st.DIGIT_E_Pin };
const f: Gpio = .{ .port = st.DIGIT_F_GPIO_Port, .pin = st.DIGIT_F_Pin };
const g: Gpio = .{ .port = st.DIGIT_G_GPIO_Port, .pin = st.DIGIT_G_Pin };
const dp: Gpio = .{ .port = st.DIGIT_DP_GPIO_Port, .pin = st.DIGIT_DP_Pin };

var digit: u32 = 0;

pub fn setDigit(next: u32) void {
    if (next == digit) return;

    switch (next % 10) {
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

    dp.write(if (next >= 10) .high else .low);

    digit = next;
}
