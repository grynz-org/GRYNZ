const std = @import("std");
const utils = @import("../utils.zig");

pub fn compileTypescript(allocator: std.mem.Allocator, io: std.Io, file: []const u8, output_dir: ?[]const u8, printWarning: bool) !void {
    var args: std.ArrayList([]const u8) = .empty;
    defer args.deinit(allocator);

    // Print the warning only if `printWarning` is true
    if (printWarning) {
        std.debug.print(
            \\Warning: You will have to manually run the compiled JavaScript file using `node`.
            \\
            , .{});
    }
    
    try args.append(allocator, "tsc");
    try args.append(allocator, file);

    // If output_dir is provided, add the --outDir flag
    if (output_dir) |dir| {
        try args.append(allocator, "--outDir");
        try args.append(allocator, dir);
    }

    // Spawn the process
    try utils.executeCommand(allocator, io, args.items);
}

pub fn runTypescript(allocator: std.mem.Allocator, io: std.Io, file: []const u8, remaining_args: []const []const u8) !void {
    // parse --out flag
    const output_dir = try utils.parseOutputDir(remaining_args);

    if (output_dir) |dir| {
        std.debug.print(
            \\Warning: A JavaScript file will be created in the specified output directory: {s}
            \\
            , .{dir});
    } else {
        std.debug.print(
            \\Warning: A JavaScript file will be created in the same directory as your TypeScript file.
            \\
            , .{});
    }

    // Compile the TypeScript file
    try compileTypescript(allocator, io, file, output_dir, false);

    var args: std.ArrayList([]const u8) = .empty;
    defer args.deinit(allocator);

    const filename = std.fs.path.basename(file);
    const dot_index = std.mem.lastIndexOfScalar(u8, filename, '.') orelse filename.len;

    // Construct the JavaScript file name
    const js_file = try std.mem.concat(allocator, u8, &.{
        filename[0..dot_index],
        ".js",
    });
    defer allocator.free(js_file);

    // Construct the path to the compiled JavaScript file
    const js_path = if (output_dir) |dir|
        try std.fs.path.join(allocator, &.{ dir, js_file })
    else
        try std.fs.path.join(allocator, &.{ std.fs.path.dirname(file) orelse ".", js_file });

    defer allocator.free(js_path);

    // Run the compiled JavaScript file using Node
    try args.append(allocator, "node");
    try args.append(allocator, js_path);

    // Spawn the process
    try utils.executeCommand(allocator, io, args.items);
}