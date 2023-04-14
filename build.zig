const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const want_lto = b.option(bool, "lto", "Want -fLTO");

    const lib = b.addStaticLibrary(.{
        .name = "ggml",
        .target = target,
        .optimize = optimize,
    });
    lib.want_lto = want_lto;
    lib.addIncludePath("include/ggml");
    lib.installHeadersDirectory("include/ggml", "ggml");
    lib.addCSourceFile("src/ggml.c", &.{});
    lib.install();
    lib.linkLibC();
}
