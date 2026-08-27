const std = @import("std");

pub fn executeCommand(allocator: std.mem.Allocator, io: std.Io, args: []const []const u8) !void {
    var child = try std.process.spawn(io, .{
        .argv = args,
        .stderr = .inherit,
        .stdout = .inherit,
    });
    _ = try child.wait(io);
    _ = allocator;
}

pub fn filterOutFlag(allocator: std.mem.Allocator, args: []const []const u8, flag: []const u8) ![]const []const u8 {
    var filtered_args: std.ArrayList([]const u8) = .empty;
    defer filtered_args.deinit(allocator);

    var i: usize = 0;
    while (i < args.len) {
        if (std.mem.eql(u8, args[i], flag)) {
            i += 2; // Skip the flag and its value
        } else {
            try filtered_args.append(allocator, args[i]);
            i += 1;
        }
    }

    return filtered_args.toOwnedSlice(allocator);
}

pub fn parseOutputDir(remaining_args: []const []const u8) !?[]const u8 {
    var output_dir: ?[]const u8 = null;

    var i: usize = 0;
    while (i < remaining_args.len) {
        if (std.mem.eql(u8, remaining_args[i], "--out")) {
            if (i + 1 < remaining_args.len) {
                output_dir = remaining_args[i + 1];
                i += 2;
            } else {
                std.debug.print("Error: --out requires an output directory\n", .{});
                return error.MissingOutputDir;
            }
        } else {
            i += 1;
        }
    }

    return output_dir;
}

pub fn readUserInput(io: std.Io) !u8 {
    const stdin_file = std.Io.File.stdin();
    var buffer: [64]u8 = undefined;
    const n = try stdin_file.readStreaming(io, &.{buffer[0..1]});
    if (n == 0) return error.EndOfStream;
    return buffer[0];
}