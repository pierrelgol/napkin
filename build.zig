const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const vaxis = b.dependency("vaxis", .{
        .target = target,
        .optimize = optimize,
    });

    const lib_mod = b.addModule("napkin", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "napkin", .module = lib_mod },
            .{ .name = "vaxis", .module = vaxis.module("vaxis") },
        },
    });

    const lib = b.addLibrary(.{
        .name = "napkin",
        .root_module = lib_mod,
    });
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "napkin",
        .root_module = exe_mod,
    });
    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const mod_tests = b.addTest(.{
        .root_module = lib_mod,
    });

    const run_mod_tests = b.addRunArtifact(mod_tests);

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);

    const lib_check = b.addLibrary(.{
        .name = "napkin",
        .root_module = lib_mod,
    });

    const exe_check = b.addExecutable(.{
        .name = "napkin",
        .root_module = exe_mod,
    });

    const check_step = b.step("check", "Run checks");
    check_step.dependOn(&lib_check.step);
    check_step.dependOn(&exe_check.step);
}
