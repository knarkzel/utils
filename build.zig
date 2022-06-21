const std = @import("std");
const utils = @import("src/main.zig");

pub fn build(b: *std.build.Builder) !void {
    b.build_root = try utils.root(b.build_root);
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("utils", "src/main.zig");
    lib.setBuildMode(mode);
    lib.install();

    const main_tests = b.addTest("src/main.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
