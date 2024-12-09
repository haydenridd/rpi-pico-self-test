const std = @import("std");
const microzig = @import("microzig");

const MicroBuild = microzig.MicroBuild(.{
    .rp2xxx = true,
});

pub fn build(b: *std.Build) void {
    const mz_dep = b.dependency("microzig", .{});
    const mb = MicroBuild.init(b, mz_dep) orelse return;

    const optimize = b.standardOptimizeOption(.{});
    const firmware = mb.add_firmware(.{
        .name = "selftest",
        .target = mb.ports.rp2xxx.boards.raspberrypi.pico,
        .optimize = optimize,
        .root_source_file = b.path("src/main.zig"),
    });

    const rtt_dep = b.dependency("rtt", .{}).module("rtt");
    firmware.add_app_import("rtt", rtt_dep, .{});

    // `install_firmware()` is the MicroZig pendant to `Build.installArtifact()`
    // and allows installing the firmware as a typical firmware file.
    //
    // This will also install into `$prefix/firmware` instead of `$prefix/bin`.
    mb.install_firmware(firmware, .{});

    // For debugging, we also always install the firmware as an ELF file
    mb.install_firmware(firmware, .{ .format = .elf });
}
