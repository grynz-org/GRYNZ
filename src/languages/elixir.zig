const std = @import("std");
const utils = @import("../utils.zig");

pub fn runElixir(allocator: std.mem.Allocator, io: std.Io, file: []const u8, remaining_args: []const []const u8) !void {
    var args: std.ArrayList([]const u8) = .empty;
    defer args.deinit(allocator);

    // Use the `elixir` command to run the file
    try args.append(allocator, "elixir");
    try args.append(allocator, file);

    // Add any remaining arguments
    for (remaining_args) |arg| {
        try args.append(allocator, arg);
    }

    // Spawn the process
    try utils.executeCommand(allocator, io, args.items);
}