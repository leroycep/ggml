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
    lib.linkLibC();
    b.installArtifact(lib);

    // utils for examples
    const example_utils_lib = b.addStaticLibrary(.{
        .name = "ggml-example-utils",
        .target = target,
        .optimize = optimize,
    });
    example_utils_lib.addCSourceFile("examples/utils.cpp", &.{"-std=c++11"});
    example_utils_lib.installHeader("examples/utils.h", "utils.h");
    example_utils_lib.linkLibCpp();

    // StableLM/GPTNeoX example
    const stablelm_example = b.addExecutable(.{
        .name = "stablelm",
        .target = target,
        .optimize = optimize,
    });
    stablelm_example.addCSourceFile("examples/stablelm/main.cpp", &.{"-std=c++11"});
    stablelm_example.linkLibrary(lib);
    stablelm_example.linkLibrary(example_utils_lib);
    b.installArtifact(stablelm_example);

    const stablelm_quantize = b.addExecutable(.{
        .name = "stablelm-quantize",
        .target = target,
        .optimize = optimize,
    });
    stablelm_quantize.addCSourceFile("examples/stablelm/quantize.cpp", &.{"-std=c++11"});
    stablelm_quantize.linkLibrary(lib);
    stablelm_quantize.linkLibrary(example_utils_lib);
    b.installArtifact(stablelm_quantize);
}
