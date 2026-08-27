const std = @import("std");
const utils = @import("../utils.zig");

pub fn compileGo(allocator: std.mem.Allocator, io: std.Io, file: []const u8, output_dir: ?[]const u8) !void {
    var args: std.ArrayList([]const u8) = .empty;
    defer args.deinit(allocator);

    try args.append(allocator, "go");
    try args.append(allocator, "build");
    try args.append(allocator, "-o");

    if (output_dir) |dir| {
        try args.append(allocator, dir);
    } else {
        try args.append(allocator, ".");
    }

    try args.append(allocator, file);

    // Spawn the process
    try utils.executeCommand(allocator, io, args.items);
}