const std = @import("std");
const utils = @import("../utils.zig");

pub fn compileJavascript(allocator: std.mem.Allocator, io: std.Io, file: []const u8, output_dir: ?[]const u8) !void {
    std.debug.print(
        \\Node doesn't create a binary, will use pkg instead.
        \\This will install Node_18 on your system.
        \\Are you sure? (y/n): 
        , .{});

    // Read user input
    const choice = utils.readUserInput(io) catch {
        std.debug.print("Failed to read input.\n", .{});
        return;
    };

    if (choice == 'y' or choice == 'Y') {
        var args: std.ArrayList([]const u8) = .empty;
        defer args.deinit(allocator);

        try args.append(allocator, "pkg");
        try args.append(allocator, file);

        // Extract the base name of the input file (without extension)
        const filename = std.fs.path.basename(file);
        const dot_index = std.mem.lastIndexOfScalar(u8, filename, '.') orelse filename.len;
        const binary_name = filename[0..dot_index];

        // Set output path
        if (output_dir) |dir| {
            const output_path = try std.fs.path.join(allocator, &.{ dir, binary_name });
            try args.append(allocator, "--output");
            try args.append(allocator, output_path);
            try args.append(allocator, "--targets");
            try args.append(allocator, "node18-win-x64");
        } else {
            try args.append(allocator, "--output");
            try args.append(allocator, binary_name);
            try args.append(allocator, "--targets");
            try args.append(allocator, "node18-win-x64");
        }

        // Spawn the process
        try utils.executeCommand(allocator, io, args.items);
    } else {
        std.debug.print("Aborted.\n", .{});
    }
}

pub fn runJavascript(allocator: std.mem.Allocator, io: std.Io, file: []const u8) !void {
    var args: std.ArrayList([]const u8) = .empty;
    defer args.deinit(allocator);

    try args.append(allocator, "node");
    try args.append(allocator, file);

    // Spawn the process
    try utils.executeCommand(allocator, io, args.items);
}