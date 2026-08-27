const std = @import("std");
const utils = @import("../utils.zig");

pub fn compileJava(allocator: std.mem.Allocator, io: std.Io, file: []const u8, output_dir: ?[]const u8) !void {
    var args: std.ArrayList([]const u8) = .empty;
    defer args.deinit(allocator);

    try args.append(allocator, "javac");
    try args.append(allocator, file);

    if (output_dir) |dir| {
        try args.append(allocator, "-d");
        try args.append(allocator, dir);
    }

    try utils.executeCommand(allocator, io, args.items);
}

pub fn runJava(allocator: std.mem.Allocator, io: std.Io, file: []const u8, remaining_args: []const []const u8) !void {
    var output_dir: ?[]const u8 = null;

    // Parse --out flag if present
    if (remaining_args.len > 1 and std.mem.eql(u8, remaining_args[0], "--out")) {
        output_dir = remaining_args[1];
    }

    // Determine the fully qualified class name from the file path
    // e.g. "langTestCodes/Main.class" -> "langTestCodes.Main"
    const no_ext = if (std.mem.endsWith(u8, file, ".class")) file[0 .. file.len - 6] else file;

    var class_name_buf: std.ArrayList(u8) = .empty;
    defer class_name_buf.deinit(allocator);

    var i: usize = 0;
    // Skip leading "./" or ".\"
    if (no_ext.len >= 2 and no_ext[0] == '.' and (no_ext[1] == '/' or no_ext[1] == '\\')) {
        i = 2;
    }

    while (i < no_ext.len) : (i += 1) {
        const c = no_ext[i];
        if (c == '/' or c == '\\') {
            try class_name_buf.append(allocator, '.');
        } else {
            try class_name_buf.append(allocator, c);
        }
    }

    const class_name = class_name_buf.items;

    var args: std.ArrayList([]const u8) = .empty;
    defer args.deinit(allocator);

    try args.append(allocator, "java");

    if (output_dir) |dir| {
        try args.append(allocator, "-cp");
        try args.append(allocator, dir);
    }

    try args.append(allocator, class_name);

    // Run Java process
    try utils.executeCommand(allocator, io, args.items);
}