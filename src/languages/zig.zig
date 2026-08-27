const std = @import("std");
const builtin = @import("builtin");
const utils = @import("../utils.zig");

pub fn compileZig(allocator: std.mem.Allocator, io: std.Io, file: []const u8, output_dir: ?[]const u8) !void {
    var args: std.ArrayList([]const u8) = .empty;
    defer args.deinit(allocator);

    try args.append(allocator, "zig");
    try args.append(allocator, "build-exe");
    try args.append(allocator, file);

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

    const emit_arg = try std.mem.concat(allocator, u8, &.{ "-femit-bin=", final_output });
    try args.append(allocator, emit_arg);

    // Spawn the process
    try utils.executeCommand(allocator, io, args.items);

    // Free allocated memory
    if (output_dir != null) allocator.free(final_output_path);
    allocator.free(final_output);
    allocator.free(emit_arg);
}

pub fn runZig(allocator: std.mem.Allocator, io: std.Io, file: []const u8) !void {
    var args: std.ArrayList([]const u8) = .empty;
    defer args.deinit(allocator);

    try args.append(allocator, "zig");
    try args.append(allocator, "run");
    try args.append(allocator, file);

    try utils.executeCommand(allocator, io, args.items);
}