const std = @import("std");
const dirname = std.fs.path.dirname;
const basename = std.fs.path.basename;

pub const UtilsError = error{BuildZigNotFound} || std.fs.OpenSelfExeError;

pub const Options = struct {
    enable_stdout: bool = false,
    enable_stderr: bool = false,
};

/// Looks for build.zig by traversing from current directory and upwards,
/// ideal for setting builder.build_root starting from builder.build_root
pub fn root(cwd: []const u8) UtilsError![]const u8 {
    const dir = try std.fs.openDirAbsolute(cwd, .{ .iterate = true });
    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        if (std.mem.eql(u8, entry.name, "build.zig")) return cwd;
    }
    return if (dirname(cwd)) |up| try root(up) else error.BuildZigNotFound;
}

test "root" {
    const dir = try root(dirname(@src().file).?);
    std.log.warn("{s}", .{dir});
}

/// Run shell command
pub fn exec(allocator: std.mem.Allocator, cwd: []const u8, argv: []const []const u8, opts: Options) !void {
    var child = try std.ChildProcess.init(argv, allocator);
    child.cwd = cwd;
    if (opts.enable_stdout) child.stdout = std.io.getStdOut() else child.stdout = null;
    if (opts.enable_stderr) child.stderr = std.io.getStdErr() else child.stderr = null;
    _ = try child.spawnAndWait();
}

/// Ensure repository exists, if not clone it with git. cwd is absolute path
pub fn ensure_repository(allocator: std.mem.Allocator, cwd: []const u8, path: []const u8, url: []const u8) !void {
    const folder = try std.fs.openDirAbsolute(cwd, .{});
    folder.access(path, .{}) catch |err| if (err == error.FileNotFound) {
        try exec(allocator, cwd, &.{ "git", "clone", url, path }, .{});
    };
}

test "ensure and exec" {
    const allocator = std.heap.page_allocator;
    const dir = try root(dirname(@src().file).?);
    try ensure_repository(allocator, dir, "utils", "https://github.com/knarkzel/utils");
    try exec(allocator, dir, &.{ "ls", "-h", "utils" }, .{});
}

/// Ensure submodules are initialized. cwd is absolute path
pub fn ensure_submodules(allocator: std.mem.Allocator, cwd: []const u8) !void {
    try exec(allocator, cwd, &.{ "git", "submodule", "update", "--init", "--recursive" }, .{});
}

/// Ensure zigmod has done initial fetch. cwd is absolute path
pub fn ensure_zigmod(allocator: std.mem.Allocator, cwd: []const u8) !void {
    const folder = try std.fs.openDirAbsolute(cwd);
    folder.access(".zigmod", .{}) catch |err| if (err == error.FileNotFound) {
        try exec(allocator, cwd, &.{ "zigmod", "fetch" }, .{});
    };
}

/// Ensure file exists, otherwise wget it. cwd is absolute path
pub fn ensure_file(allocator: std.mem.Allocator, cwd: []const u8, path: []const u8, url: []const u8) !void {
    const folder = try std.fs.openDirAbsolute(cwd, .{});
    folder.access(path, .{}) catch |err| if (err == error.FileNotFound) {
        try exec(allocator, cwd, &.{ "wget", "-q", url }, .{});
    };
}

test "ensure_file and exec" {
    const allocator = std.heap.page_allocator;
    const dir = try root(dirname(@src().file).?);
    const file = "main.zig";
    try ensure_file(allocator, dir, file, "https://raw.githubusercontent.com/knarkzel/utils/master/src/main.zig");
    try exec(allocator, dir, &.{ "sha256sum", file }, .{});
    const folder = try std.fs.openDirAbsolute(dir, .{});
    try folder.deleteFile(file);
}

/// Ensure path exists, otherwise wget and extract it with tar. cwd is absolute path
pub fn ensure_tar(allocator: std.mem.Allocator, cwd: []const u8, path: []const u8, url: []const u8) !void {
    const folder = try std.fs.openDirAbsolute(cwd, .{});
    folder.access(path, .{}) catch |err| if (err == error.FileNotFound) {
        try exec(allocator, cwd, &.{ "wget", "-q", url }, .{});
        try exec(allocator, cwd, &.{ "tar", "-xf", basename(url) }, .{});
        try folder.deleteFile(basename(url));
    };
}

test "ensure_tar" {
    const allocator = std.heap.page_allocator;
    const dir = try root(dirname(@src().file).?);
    const path = "gbdk";
    try ensure_tar(allocator, dir, path, "https://github.com/gbdk-2020/gbdk-2020/releases/download/4.0.6/gbdk-linux64.tar.gz");
}
