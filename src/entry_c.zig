const mx = @import("stm32cubemx");

const entry = @import("entry.zig").entry;

export fn entry_c() void {
    entry() catch mx.Error_Handler();
}
