const std = @import("std");
const utils = @import("../utils.zig");

pub fn compileKotlin(allocator: std.mem.Allocator, io: std.Io, file: []const u8, output_dir: ?[]const u8, remaining_args: []const []const u8) !void {
    var include_runtime = false;

    // Filter out --out and its value from remaining_args
    const filtered_args = try utils.filterOutFlag(allocator, remaining_args, "--out");
    defer allocator.free(filtered_args);

    // Parse remaining arguments for -include-runtime
    var i: usize = 0;
    while (i < filtered_args.len) {
        if (std.mem.eql(u8, filtered_args[i], "-include-runtime")) {
            include_runtime = true;
            i += 1;
        } else {
            std.debug.print("Unknown argument: {s}\n", .{filtered_args[i]});
            return error.UnknownArgument;
        }
    }

    var args: std.ArrayList([]const u8) = .empty;
    defer args.deinit(allocator);

    try args.append(allocator, "kotlinc");
    try args.append(allocator, file);

    // Add -include-runtime flag if specified
    if (include_runtime) {
        try args.append(allocator, "-include-runtime");
    }

    // Determine the output JAR path
    const filename = std.fs.path.basename(file);
    const dot_index = std.mem.lastIndexOfScalar(u8, filename, '.') orelse filename.len;
    const name = filename[0..dot_index];
    const jar_name = try std.mem.concat(allocator, u8, &.{ name, ".jar" });

    var final_output_path: []const u8 = undefined;
    if (output_dir) |dir| {
        final_output_path = try std.fs.path.join(allocator, &.{ dir, jar_name });
    } else {
        final_output_path = jar_name;
    }

    // Add the output argument
    const output_arg = try std.mem.concat(allocator, u8, &.{ "-d=", final_output_path });
    try args.append(allocator, output_arg);

    // Execute the command
    try utils.executeCommand(allocator, io, args.items);

    // Free allocated memory
    if (output_dir != null) allocator.free(final_output_path);
    allocator.free(jar_name);
    allocator.free(output_arg);
}

pub fn runKotlin(allocator: std.mem.Allocator, io: std.Io, jar_file: []const u8) !void {
    var args: std.ArrayList([]const u8) = .empty;
    defer args.deinit(allocator);

    try args.append(allocator, "java");
    try args.append(allocator, "-jar");
    try args.append(allocator, jar_file);

    // Execute the command
    try utils.executeCommand(allocator, io, args.items);
}