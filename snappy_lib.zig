const std = @import("std");

pub fn configure(
    comptime basedir: []const u8,
    comptime dep_dirs: anytype,
    comptime root_dep_dirs: anytype,
    allocator: std.mem.Allocator,
    lib: *std.build.LibExeObjStep,
    target: std.zig.CrossTarget,
    mode: std.builtin.Mode,
) *std.build.LibExeObjStep {
    _ = root_dep_dirs;
    _ = allocator;
    
    lib.setTarget(target);
    lib.setBuildMode(mode);

    lib.linkLibC();
    lib.linkLibCpp();
    
    lib.addIncludeDir(basedir ++ "/include");
    lib.addSystemIncludeDir(dep_dirs.get("zpp").? ++ "/include");
    lib.addIncludeDir(basedir ++ "/snappy");
    switch (target.getOsTag()) {
        .windows => {
            lib.addIncludeDir(basedir ++ "/snappy/gn-platform/win");
        },
        .macos => {
            lib.addIncludeDir(basedir ++ "/snappy/gn-platform/mac");
        },
        else => {
            lib.addIncludeDir(basedir ++ "/snappy/gn-platform/linux");
        }
    }
    lib.addCSourceFiles(&.{
        basedir ++ "/src/lib.cpp",
        basedir ++ "/snappy/snappy-c.cc",
        basedir ++ "/snappy/snappy-sinksource.cc",
        basedir ++ "/snappy/snappy-stubs-internal.cc",
        basedir ++ "/snappy/snappy.cc",
    }, &.{
        "-std=c++14",
        "-Wall",
        "-Wextra",
        "-Werror",
        "-fno-exceptions",
        "-fno-rtti",
        "-DNDEBUG",
        "-DHAVE_CONFIG_H",
    });

    return lib;
}
