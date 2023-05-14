const std = @import("std");

const ComputeFramework = enum {
    accelerate,
    openblas,
    cublas,
    clblast,
};

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const want_lto = b.option(bool, "lto", "Want -fLTO");
    const compute_framework = b.option(ComputeFramework, "compute-framework", "Specify a library to perform computations (default: none)");

    const lib = b.addStaticLibrary(.{
        .name = "ggml",
        .target = target,
        .optimize = optimize,
    });
    lib.want_lto = want_lto;
    lib.c_std = .C11;
    lib.addIncludePath("include/ggml");
    lib.installHeadersDirectory("include/ggml", "ggml");
    lib.addCSourceFile("src/ggml.c", &.{});
    lib.linkLibC();
    if (compute_framework) |framework| {
        switch (framework) {
            .accelerate => {
                lib.defineCMacro("GGML_USE_ACCELERATE", "1");
            },
            .openblas => {
                lib.defineCMacro("GGML_USE_OPENBLAS", "1");
                lib.linkSystemLibrary("openblas");
            },
            .cublas => {
                lib.defineCMacro("GGML_USE_CUBLAS", "1");
            },
            .clblast => {
                const clblast = b.dependency("clblast", .{
                    .target = target,
                    .optimize = optimize,
                });

                lib.addCSourceFile("src/ggml-opencl.c", &.{});
                lib.defineCMacro("GGML_USE_CLBLAST", "1");
                lib.linkLibrary(clblast.artifact("clblast"));
            },
        }
    }
    b.installArtifact(lib);

    // utils for examples
    const example_common_lib = b.addStaticLibrary(.{
        .name = "common",
        .target = target,
        .optimize = optimize,
    });
    example_common_lib.addCSourceFile("examples/common.cpp", &.{"-std=c++11"});
    example_common_lib.installHeader("examples/common.h", "common.h");
    example_common_lib.linkLibCpp();

    const example_common_ggml_lib = b.addStaticLibrary(.{
        .name = "common-ggml",
        .target = target,
        .optimize = optimize,
    });
    example_common_ggml_lib.linkLibrary(lib);
    example_common_ggml_lib.addCSourceFile("examples/common-ggml.cpp", &.{"-std=c++11"});
    example_common_ggml_lib.installHeader("examples/common-ggml.h", "common-ggml.h");
    example_common_ggml_lib.linkLibCpp();

    // StableLM/GPTNeoX example
    const stablelm_example = b.addExecutable(.{
        .name = "stablelm",
        .target = target,
        .optimize = optimize,
    });
    stablelm_example.addCSourceFile("examples/stablelm/main.cpp", &.{"-std=c++11"});
    stablelm_example.linkLibrary(lib);
    stablelm_example.linkLibrary(example_common_lib);
    stablelm_example.linkLibrary(example_common_ggml_lib);
    b.installArtifact(stablelm_example);

    const stablelm_quantize = b.addExecutable(.{
        .name = "stablelm-quantize",
        .target = target,
        .optimize = optimize,
    });
    stablelm_quantize.addCSourceFile("examples/stablelm/quantize.cpp", &.{"-std=c++11"});
    stablelm_quantize.linkLibrary(lib);
    stablelm_quantize.linkLibrary(example_common_lib);
    stablelm_quantize.linkLibrary(example_common_ggml_lib);
    b.installArtifact(stablelm_quantize);

    // Replit example
    const replit_example = b.addExecutable(.{
        .name = "replit",
        .target = target,
        .optimize = optimize,
    });
    replit_example.addCSourceFile("examples/replit/main.cpp", &.{"-std=c++11"});
    replit_example.linkLibrary(lib);
    replit_example.linkLibrary(example_common_lib);
    replit_example.linkLibrary(example_common_ggml_lib);
    b.installArtifact(replit_example);

    const replit_quantize = b.addExecutable(.{
        .name = "replit-quantize",
        .target = target,
        .optimize = optimize,
    });
    replit_quantize.addCSourceFile("examples/replit/quantize.cpp", &.{"-std=c++11"});
    replit_quantize.linkLibrary(lib);
    replit_quantize.linkLibrary(example_common_lib);
    replit_quantize.linkLibrary(example_common_ggml_lib);
    b.installArtifact(replit_quantize);

    // MPT example
    const mpt_example = b.addExecutable(.{
        .name = "mpt",
        .target = target,
        .optimize = optimize,
    });
    mpt_example.addCSourceFile("examples/mpt/main.cpp", &.{"-std=c++11"});
    mpt_example.linkLibrary(lib);
    mpt_example.linkLibrary(example_common_lib);
    mpt_example.linkLibrary(example_common_ggml_lib);
    b.installArtifact(mpt_example);

    const mpt_quantize = b.addExecutable(.{
        .name = "mpt-quantize",
        .target = target,
        .optimize = optimize,
    });
    mpt_quantize.addCSourceFile("examples/mpt/quantize.cpp", &.{"-std=c++11"});
    mpt_quantize.linkLibrary(lib);
    mpt_quantize.linkLibrary(example_common_lib);
    mpt_quantize.linkLibrary(example_common_ggml_lib);
    b.installArtifact(mpt_quantize);
}
