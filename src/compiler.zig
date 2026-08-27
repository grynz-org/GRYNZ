const std = @import("std");
const builtin = @import("builtin");
const c = @import("languages/c.zig");
const cpp = @import("languages/cpp.zig");
const elixir = @import("languages/elixir.zig");
const erlang = @import("languages/erlang.zig");
const go = @import("languages/go.zig");
const java = @import("languages/java.zig");
const javascript = @import("languages/javascript.zig");
const kotlin = @import("languages/kotlin.zig");
const python = @import("languages/python.zig");
const rust = @import("languages/rust.zig");
const typescript = @import("languages/typescript.zig");
const zigc = @import("languages/zig.zig");
const utils = @import("utils.zig");

pub fn handleBuild(allocator: std.mem.Allocator, io: std.Io, file: []const u8, remaining_args: []const []const u8) !void {

    const output_dir = try utils.parseOutputDir(remaining_args);

    // Create output directory if it doesn't exist
    if (output_dir) |dir| {
        const cwd = std.Io.Dir.cwd();
        cwd.createDir(io, dir, .default_dir) catch |err| {
            if (err != error.PathAlreadyExists) {
                return err;
            }
        };
    }

    if (std.mem.endsWith(u8, file, ".c")) {
        try c.compileC(allocator, io, file, output_dir);
    } else if (std.mem.endsWith(u8, file, ".cpp")) {
        try cpp.compileCpp(allocator, io, file, output_dir);
    } else if (std.mem.endsWith(u8, file, ".erl")) {
        try erlang.compileErlang(allocator, io, file, output_dir);
    } else if (std.mem.endsWith(u8, file, ".go")) {
        try go.compileGo(allocator, io, file, output_dir);
    } else if (std.mem.endsWith(u8, file, ".java")) {
        try java.compileJava(allocator, io, file, output_dir);
    } else if (std.mem.endsWith(u8, file, ".js")) {
        try javascript.compileJavascript(allocator, io, file, output_dir);
    } else if (std.mem.endsWith(u8, file, ".kt")) {
        try kotlin.compileKotlin(allocator, io, file, output_dir, remaining_args);
    } else if (std.mem.endsWith(u8, file, ".py")) {
        try python.compilePython(allocator, io, file, output_dir);
    } else if (std.mem.endsWith(u8, file, ".rs")) {
        try rust.compileRust(allocator, io, file, output_dir);
    } else if (std.mem.endsWith(u8, file, ".ts")) {
        try typescript.compileTypescript(allocator, io, file, output_dir, true);
    } else if (std.mem.endsWith(u8, file, ".zig")) {
        try zigc.compileZig(allocator, io, file, output_dir);
    } else {
        std.debug.print("Unsupported file type: {s}\n", .{file});
        return;
    }
}

pub fn handleRun(allocator: std.mem.Allocator, io: std.Io, file: []const u8, remaining_args: []const []const u8) !void {
    if (std.mem.endsWith(u8, file, ".beam")) {
        try erlang.runErlang(allocator, io, file, remaining_args);
    } else if (std.mem.endsWith(u8, file, ".class")) {
        try java.runJava(allocator, io, file, remaining_args);
    } else if (std.mem.endsWith(u8, file, ".ex") or std.mem.endsWith(u8, file, ".exs")) {
        try elixir.runElixir(allocator, io, file, remaining_args);
    } else if (std.mem.endsWith(u8, file, ".js")) {
        try javascript.runJavascript(allocator, io, file);
    } else if (std.mem.endsWith(u8, file, ".jar")) {
        try kotlin.runKotlin(allocator, io, file);
    } else if (std.mem.endsWith(u8, file, ".py")) {
        try python.runPython(allocator, io, file);
    } else if (std.mem.endsWith(u8, file, ".ts")) {
        try typescript.runTypescript(allocator, io, file, remaining_args);
    } else if (std.mem.endsWith(u8, file, ".zig")) {
        try zigc.runZig(allocator, io, file);
    } else {
        std.debug.print("Unsupported file type for run command: {s}\n", .{file});
        return;
    }
}