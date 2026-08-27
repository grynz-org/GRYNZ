const std = @import("std");
const compiler = @import("compiler.zig");

// Define the version as a comptime constant
const version = "0.7.0-alpha";

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;
    const io = init.io;

    // Collect command line arguments into a slice
    var arg_list: std.ArrayList([]const u8) = .empty;
    defer arg_list.deinit(allocator);

    var args_iter = try std.process.Args.Iterator.initAllocator(init.minimal.args, allocator);
    defer args_iter.deinit();

    while (args_iter.next()) |arg| {
        try arg_list.append(allocator, arg);
    }

    const args = arg_list.items;

    if (args.len < 2) {
        std.debug.print("Usage: grynz <command> [options]\n", .{});
        std.debug.print("Commands:\n", .{});
        std.debug.print("  build <file> [--out <output_dir>] - Compile a file\n", .{});
        std.debug.print("  run <file> [options] - Run a file\n", .{});
        std.debug.print("  --version - Print the version\n", .{});
        return;
    }

    const command = args[1];

    // Handle --version flag
    if (std.mem.eql(u8, command, "--version")) {
        std.debug.print("Grynz version: {s}\n", .{version});
        return;
    }

    if (args.len < 3) {
        std.debug.print("Usage: grynz <command> [options]\n", .{});
        return;
    }

    const file = args[2];

    if (std.mem.eql(u8, command, "build")) {
        try compiler.handleBuild(allocator, io, file, args[3..]);
    } else if (std.mem.eql(u8, command, "run")) {
        try compiler.handleRun(allocator, io, file, args[3..]);
    } else {
        std.debug.print("Unknown command: {s}\n", .{command});
    }
}