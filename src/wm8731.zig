const mx = @import("stm32cubemx");

extern var hi2c1: mx.I2C_HandleTypeDef;

pub const Error = error{WriteFailed};

var db_prev: ?i8 = null;

pub fn init() Error!void {
    try write(0x0F, 0x000); // R15 Reset Register
    try write(0x06, 0x077); // R6 Power Down Control
    try write(0x04, 0x010); // R4 Analogue Audio Path Control
    try write(0x05, 0x000); // R5 Digital Audio Path Control
    try write(0x07, 0x002); // R7 Digital Audio Interface Format
    try write(0x08, 0x020); // R8 Sampling Control
    try write(0x09, 0x001); // R9 Active Control
    try write(0x06, 0x067); // R6 Power Down Control
}

pub fn setVolume(db: i8) void {
    if (db == db_prev) return;
    if (db < -73 or db > 6) return;
    write(0x02, @intCast(@as(i16, db) + 121)) catch return;
    write(0x03, @intCast(@as(i16, db) + 121)) catch return;
    db_prev = db;
}

fn write(reg: u8, value: u16) Error!void {
    var payload: [2]u8 = .{
        @truncate((@as(u16, reg) << 1) | ((value >> 8) & 0x01)),
        @truncate(value),
    };
    if (mx.HAL_I2C_Master_Transmit(&hi2c1, 0x1A << 1, &payload, payload.len, 50) != mx.HAL_OK) {
        return Error.WriteFailed;
    }
}
