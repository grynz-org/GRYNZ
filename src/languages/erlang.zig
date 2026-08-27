const std = @import("std");
const utils = @import("../utils.zig");

pub fn compileErlang(allocator: std.mem.Allocator, io: std.Io, file: []const u8, output_dir: ?[]const u8) !void {
    var args: std.ArrayList([]const u8) = .empty;
    defer args.deinit(allocator);

    try args.append(allocator, "erlc");

    if (output_dir) |dir| {
        try args.append(allocator, "-o");
        try args.append(allocator, dir);
    }

    try args.append(allocator, file);

    try utils.executeCommand(allocator, io, args.items);
}

pub fn runErlang(allocator: std.mem.Allocator, io: std.Io, file: []const u8, remaining_args: []const []const u8) !void {
    var entry_function: ?[]const u8 = null;

    // Parse remaining arguments for --entry
    var i: usize = 0;
    while (i < remaining_args.len) {
        if (std.mem.eql(u8, remaining_args[i], "--entry")) {
            if (i + 1 < remaining_args.len) {
                entry_function = remaining_args[i + 1];
                i += 2;
            } else {
                std.debug.print("Error: --entry requires an entry function\n", .{});
                return error.MissingEntryFunction;
            }
        } else {
            std.debug.print("Unknown argument: {s}\n", .{remaining_args[i]});
            return error.UnknownArgument;
        }
    }

    if (entry_function == null) {
        std.debug.print("Error: --entry flag is required for running Erlang files\n", .{});
        return error.MissingEntryFunction;
    }

    // Extract module name without extension
    const filename = std.fs.path.basename(file);
    const dot_index = std.mem.lastIndexOfScalar(u8, filename, '.') orelse filename.len;
    const module_name = filename[0..dot_index];

    var args: std.ArrayList([]const u8) = .empty;
    defer args.deinit(allocator);

    try args.append(allocator, "erl");

    // Use the directory of the file as the classpath
    const file_dir = std.fs.path.dirname(file) orelse ".";
    try args.append(allocator, "-pa");
    try args.append(allocator, file_dir);

    try args.append(allocator, "-noshell");
    try args.append(allocator, "-s");
    try args.append(allocator, module_name);
    try args.append(allocator, entry_function.?);
    try args.append(allocator, "-s");
    try args.append(allocator, "init");
    try args.append(allocator, "stop");

    try utils.executeCommand(allocator, io, args.items);
}