const st = @import("stm32cubemx");

pub const State = enum {
    low,
    high,
};

port: *st.GPIO_TypeDef,
pin: u16,

pub fn read(self: *const @This()) State {
    return switch (st.HAL_GPIO_ReadPin(self.port, self.pin)) {
        st.GPIO_PIN_RESET => .low,
        st.GPIO_PIN_SET => .high,
        else => unreachable,
    };
}

pub fn write(self: *const @This(), state: State) void {
    st.HAL_GPIO_WritePin(self.port, self.pin, switch (state) {
        .low => st.GPIO_PIN_RESET,
        .high => st.GPIO_PIN_SET,
    });
}
