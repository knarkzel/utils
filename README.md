# utils

Collection of useful functions for `build.zig`.
Examples are listed in the source code.

## Getting started

```bash
curl https://raw.githubusercontent.com/knarkzel/utils/master/src/main.zig -o utils.zig
```

## Documentation

```zig
pub const Options = struct {
    enable_stdout: bool = false,
    enable_stderr: bool = false,
};

/// Looks for build.zig by traversing from current directory and upwards,
/// ideal for setting builder.build_root starting from builder.build_root
pub fn root(cwd: []const u8) UtilsError![]const u8

/// Run shell command
pub fn exec(allocator: std.mem.Allocator, cwd: []const u8, argv: []const []const u8, opts: Options) !void

/// Ensure repository exists, if not clone it with git. cwd is absolute path
pub fn ensure_repository(allocator: std.mem.Allocator, cwd: []const u8, path: []const u8, url: []const u8) !void

/// Ensure submodules are initialized. cwd is absolute path
pub fn ensure_submodules(allocator: std.mem.Allocator, cwd: []const u8) !void

/// Ensure zigmod has done initial fetch. cwd is absolute path
pub fn ensure_zigmod(allocator: std.mem.Allocator, cwd: []const u8) !void

/// Ensure file exists, otherwise wget it. cwd is absolute path
pub fn ensure_file(allocator: std.mem.Allocator, cwd: []const u8, path: []const u8, url: []const u8) !void

/// Ensure path exists, otherwise wget and extract it with tar. cwd is absolute path
pub fn ensure_tar(allocator: std.mem.Allocator, cwd: []const u8, path: []const u8, url: []const u8) !void
```
