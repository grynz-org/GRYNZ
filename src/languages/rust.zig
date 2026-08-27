const std = @import("std");
const builtin = @import("builtin");
const utils = @import("../utils.zig");

pub fn compileRust(allocator: std.mem.Allocator, io: std.Io, file: []const u8, output_dir: ?[]const u8) !void {
    var args: std.ArrayList([]const u8) = .empty;
    defer args.deinit(allocator);

    try args.append(allocator, "rustc");
    try args.append(allocator, file);
    try args.append(allocator, "-o");

    // Extract filename without extension
    const filename = std.fs.path.basename(file);
    const dot_index = std.mem.lastIndexOfScalar(u8, filename, '.') orelse filename.len;
    const name = filename[0..dot_index];

    // Ensure a correct output path
    var final_output_path: []const u8 = undefined;
    if (output_dir) |dir| {
        final_output_path = try std.fs.path.join(allocator, &.{ dir, name });
    } else {
        final_output_path = name;
    }

    // Ensure `.exe` extension on Windows
    const ext = if (builtin.os.tag == .windows) ".exe" else "";
    const final_output = try std.mem.concat(allocator, u8, &.{ final_output_path, ext });
    try args.append(allocator, final_output);

    // Spawn the process
    try utils.executeCommand(allocator, io, args.items);

    // Free allocated memory
    if (output_dir != null) allocator.free(final_output_path);
    allocator.free(final_output);
}
