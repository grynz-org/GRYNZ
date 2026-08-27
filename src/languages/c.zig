const std = @import("std");
const utils = @import("../utils.zig");

pub fn compileC(allocator: std.mem.Allocator, io: std.Io, file: []const u8, output_dir: ?[]const u8) !void {
    var args: std.ArrayList([]const u8) = .empty;
    defer args.deinit(allocator);

    try args.append(allocator, "gcc");
    try args.append(allocator, file);
    try args.append(allocator, "-o");

    // Construct output path
    const filename = std.fs.path.basename(file);
    const dot_index = std.mem.lastIndexOfScalar(u8, filename, '.') orelse filename.len;
    const name = filename[0..dot_index];

    if (output_dir) |dir| {
        // Join directory with filename
        const output = try std.fs.path.join(allocator, &.{ dir, name });
        defer allocator.free(output);
        try args.append(allocator, output);

        // Spawn the process
        try utils.executeCommand(allocator, io, args.items);
    } else {
        // Just use filename in current directory
        try args.append(allocator, name);

        // Spawn the process
        try utils.executeCommand(allocator, io, args.items);
    }
}