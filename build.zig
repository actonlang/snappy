const std = @import("std");
const print = @import("std").debug.print;

pub fn build(b: *std.build.Builder) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    var flags = std.ArrayList([]const u8).init(b.allocator);
    defer flags.deinit();

    const lib = b.addStaticLibrary(.{
        .name = "snappy-c",
        .target = target,
        .optimize = optimize,
    });
    lib.addIncludePath(.{ .path = "." });

    //const libsnappy_version = "1.1.10";

    const config_header = b.addConfigHeader(
        .{
            .style = .blank,
        },
        .{
            .HAVE_ATTRIBUTE_ALWAYS_INLINE = true,
            .HAVE_BUILTIN_CTZ = true,
            .HAVE_BUILTIN_EXPECT = true,
            .HAVE_BUILTIN_PREFETCH = true,
            .HAVE_FUNC_MMAP = true,
            .HAVE_FUNC_SYSCONF = true,
            .HAVE_LIBLZO2 = false,
            .HAVE_LIBZ = true,
            .HAVE_LIBLZ4 = false,
            .HAVE_SYS_MMAN_H = true,
            .HAVE_SYS_RESOURCE_H = true,
            .HAVE_SYS_TIME_H = true,
            .HAVE_SYS_UIO_H = true,
            .HAVE_UNISTD_H = true,
            .HAVE_WINDOWS_H = false,
            .SNAPPY_HAVE_SSSE3 = false,
            .SNAPPY_HAVE_X86_CRC32 = false,
            .SNAPPY_HAVE_BMI2 = false,
            .SNAPPY_HAVE_NEON = false,
            .SNAPPY_HAVE_NEON_CRC32 = false,
            .SNAPPY_IS_BIG_ENDIAN = false,
        },
    );
    lib.addConfigHeader(config_header);

    const public_header = b.addConfigHeader(
        .{
            .style = .{ .cmake = .{ .path = "snappy-stubs-public.h.in" } },
            .include_path = "snappy-stubs-public.h",
        },
        .{
            .HAVE_SYS_UIO_H_01 = true,
        },
    );
    lib.addConfigHeader(public_header);

    //flags.appendSlice(&.{
    //    "-std=c++11",
    //}) catch unreachable;

    const source_files = [_][]const u8{
        "snappy-sinksource.cc",
        "snappy-stubs-internal.cc",
        "snappy.cc",
        "snappy-c.cc",
    };

    lib.linkLibC();
    lib.linkLibCpp();
    lib.installHeader("snappy-c.h", "snappy-c.h");
    lib.addCSourceFiles(.{
        .files = &source_files,
        .flags = flags.items
    });

    b.installArtifact(lib);
}
