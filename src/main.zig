const std = @import("std");
const compiler = @import("compiler.zig");

// Define the version as a comptime constant
const version = "0.6.0-alpha";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

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
        try compiler.handleBuild(file, args[3..]);
    } else if (std.mem.eql(u8, command, "run")) {
        try compiler.handleRun(file, args[3..]);
    } else {
        std.debug.print("Unknown command: {s}\n", .{command});
    }
}

// Just checking git connection