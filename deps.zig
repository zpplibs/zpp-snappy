const std = @import("std");
const builtin = @import("builtin");
const Pkg = std.build.Pkg;
const string = []const u8;

pub const cache = ".zigmod/deps";

pub fn addAllTo(
    exe: *std.build.LibExeObjStep,
    b: *std.build.Builder,
    target: std.zig.CrossTarget,
    mode: std.builtin.Mode,
) *std.build.LibExeObjStep {
    @setEvalBranchQuota(1_000_000);

    exe.setTarget(target);
    exe.setBuildMode(mode);

    // lazy
    if (c_libs[0] == null) resolveCLibs(b, target, mode);
    for (c_libs) |c_lib| exe.linkLibrary(c_lib.?);

    for (packages) |pkg| {
        exe.addPackage(pkg.pkg.?);
    }
    inline for (std.meta.declarations(package_data)) |decl| {
        const pkg = @as(Package, @field(package_data, decl.name));
        inline for (pkg.system_libs) |item| {
            exe.linkSystemLibrary(item);
        }
        inline for (pkg.c_include_dirs) |item| {
            exe.addIncludeDir(@field(dirs, decl.name) ++ "/" ++ item);
        }
        inline for (pkg.c_source_files) |item| {
            exe.addCSourceFile(@field(dirs, decl.name) ++ "/" ++ item, pkg.c_source_flags);
        }
    }

    exe.linkLibC();

    return exe;
}

pub const CLib = struct {
    name: string,
    idx: usize,
    pub fn getStep(self: *CLib) ?*std.build.LibExeObjStep {
        return c_libs[self.idx];
    }
};

pub const Package = struct {
    directory: string,
    pkg: ?Pkg = null,
    c_include_dirs: []const string = &.{},
    c_libs: []const CLib = &.{},
    c_source_files: []const string = &.{},
    c_source_flags: []const string = &.{},
    system_libs: []const string = &.{},
    vcpkg: bool = false,
};

pub const dirs = struct {
    pub const _root = "";
    pub const _u8xgq6eugih6 = ".";
    pub const _f3itt0eg63fb = cache ++ "/v/git/github.com/zpplibs/zpp/branch-master";
};

const zero_deps_map = std.ComptimeStringMap(string, .{ .{ "", "" } });

pub const dep_dirs = struct {
    pub const _root = std.ComptimeStringMap(string, .{
        .{ "zpp-snappy", dirs._u8xgq6eugih6 },
        .{ "zpp", dirs._f3itt0eg63fb },
    });
    pub const _u8xgq6eugih6 = std.ComptimeStringMap(string, .{
        .{ "zpp", dirs._f3itt0eg63fb },
    });
    pub const _f3itt0eg63fb = zero_deps_map;
};

pub const package_data = struct {
    pub const _f3itt0eg63fb = Package{
        .directory = dirs._f3itt0eg63fb,
        .pkg = Pkg{ .name = "zpp", .path = .{ .path = dirs._f3itt0eg63fb ++ "/src/lib.zig" }, .dependencies = null },
        .c_include_dirs = &.{ "include" },
    };
    pub const _u8xgq6eugih6 = Package{
        .directory = dirs._u8xgq6eugih6,
        .pkg = Pkg{ .name = "zpp-snappy", .path = .{ .path = dirs._u8xgq6eugih6 ++ "/src/lib.zig" }, .dependencies = &.{ _f3itt0eg63fb.pkg.? } },
        .c_include_dirs = &.{ "include", "snappy" },
        .c_libs = &.{
            .{ .name = "snappy", .idx = 0 },
        },
    };
    pub const _root = Package{
        .directory = dirs._root,
    };
};

pub const packages = &[_]Package{
    package_data._u8xgq6eugih6,
    package_data._f3itt0eg63fb,
};

pub const pkgs = struct {
    pub const zpp_snappy = package_data._u8xgq6eugih6;
    pub const zpp = package_data._f3itt0eg63fb;
};


// lazy
var c_libs: [1]?*std.build.LibExeObjStep = undefined;

fn resolveCLibs(
    b: *std.build.Builder,
    target: std.zig.CrossTarget,
    mode: std.builtin.Mode,
) void {
    c_libs[0] = @import(".zigmod/deps/../../snappy_lib.zig").configure(
        dirs._u8xgq6eugih6,
        dep_dirs._u8xgq6eugih6,
        dep_dirs._root,
        b.allocator,
        b.addStaticLibrary("snappy", null),
        target, mode,
    );
}

