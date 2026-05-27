const mx = @import("stm32cubemx");

pub const State = enum {
    low,
    high,
};

port: *mx.GPIO_TypeDef,
pin: u16,

pub fn read(self: *const @This()) State {
    return switch (mx.HAL_GPIO_ReadPin(self.port, self.pin)) {
        mx.GPIO_PIN_RESET => .low,
        mx.GPIO_PIN_SET => .high,
        else => unreachable,
    };
}

pub fn write(self: *const @This(), state: State) void {
    mx.HAL_GPIO_WritePin(self.port, self.pin, switch (state) {
        .low => mx.GPIO_PIN_RESET,
        .high => mx.GPIO_PIN_SET,
    });
}
