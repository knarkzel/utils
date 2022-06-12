const std = @import("std");
const dirname = std.fs.path.dirname;

const RootError = error{NotFound} || std.fs.OpenSelfExeError;

/// Looks for build.zig by traversing from current directory and upwards, ideal to pass builder.build_root
pub fn find(cwd: []const u8) RootError![]const u8 {
    const dir = try std.fs.openDirAbsolute(cwd, .{ .iterate = true });
    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        if (std.mem.eql(u8, entry.name, "build.zig")) return cwd;
    }
    return if (dirname(cwd)) |up| try find(up) else error.NotFound;
}

test "root" {
    const dir = try find(dirname(@src().file).?);
    std.log.warn("{s}", .{dir});
}
