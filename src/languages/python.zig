const std = @import("std");
const utils = @import("../utils.zig");

pub fn compilePython(allocator: std.mem.Allocator, io: std.Io, file: []const u8, output_dir: ?[]const u8) !void {
    // Warning to the user
    std.debug.print(
        \\ Python does not natively compile to binaries.
        \\ You can use the `run` command instead:
        \\ Example: grynz run {s}
        \\ 
        \\ Press 'R' to run the script now.
        \\ Press 'Y' to continue compilation.
        \\ Press 'N' to exit.
        \\ > 
    , .{file});

    // Read user input
    const choice = utils.readUserInput(io) catch {
        std.debug.print("Failed to read input.\n", .{});
        return;
    };

    if (choice == 'R' or choice == 'r') {
        try runPython(allocator, io, file);
        return;
    } else if (choice == 'N' or choice == 'n') {
        std.debug.print("\nExiting. Use `grynz run {s}` to execute the script.\n", .{file});
        return;
    }

    // Proceed with compilation
    var args: std.ArrayList([]const u8) = .empty;
    defer args.deinit(allocator);

    try args.append(allocator, "python");
    try args.append(allocator, "-m");
    try args.append(allocator, "nuitka");
    try args.append(allocator, "--standalone");
    try args.append(allocator, "--onefile");
    try args.append(allocator, file);

    if (output_dir) |dir| {
        const out_flag = try std.mem.concat(allocator, u8, &.{"--output-dir=", dir});
        try args.append(allocator, out_flag);
    }

    // Spawn the process
    try utils.executeCommand(allocator, io, args.items);
}


pub fn runPython(allocator: std.mem.Allocator, io: std.Io, file: []const u8) !void {
    var args: std.ArrayList([]const u8) = .empty;
    defer args.deinit(allocator);

    try args.append(allocator, "python");
    try args.append(allocator, file);

    // Spawn the process
    try utils.executeCommand(allocator, io, args.items);
}