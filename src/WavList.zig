const std = @import("std");
const st = @import("stm32cubemx");

const Directory = @import("fatfs.zig").Directory;

comptime {
    if (st._USE_LFN != 0) @compileError("LFN is not supported.");
}

pub const Error = std.mem.Allocator.Error || Directory.Error;

allocator: std.mem.Allocator,
file_names: std.ArrayList([:0]const u8),

pub fn init(allocator: std.mem.Allocator, path: [:0]const u8) Error!@This() {
    var self: @This() = .{
        .allocator = allocator,
        .file_names = .empty,
    };
    errdefer self.deinit();

    var dir = try Directory.open(path);
    defer dir.close();

    while (true) {
        const file_info = try dir.read();
        const file_name = std.mem.sliceTo(&file_info.fname, 0);

        if (file_name.len == 0) break;
        if ((file_info.fattrib & st.AM_DIR) != 0) continue;
        if (!std.mem.endsWith(u8, file_name, ".WAV")) continue;

        const file_name_owned = try self.allocator.dupeZ(u8, file_name);
        errdefer self.allocator.free(file_name_owned);
        try self.file_names.append(self.allocator, file_name_owned);
    }

    std.mem.sort([:0]const u8, self.file_names.items, {}, lessThan);

    return self;
}

pub fn deinit(self: *@This()) void {
    for (self.file_names.items) |file_name| {
        self.allocator.free(file_name);
    }
    self.file_names.deinit(self.allocator);
}

pub fn names(self: *const @This()) []const [:0]const u8 {
    return self.file_names.items;
}

fn lessThan(_: void, a: [:0]const u8, b: [:0]const u8) bool {
    return std.mem.lessThan(u8, a, b);
}
