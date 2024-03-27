// https://github.com/mattnite/zig-zlib

const std = @import("std");
const Self = @This();

fn root() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}

const root_path = root() ++ "/";
const package_path = root_path ++ "src/main.zig";
pub const include_dir = root_path ++ "zlib";
pub const Options = struct {
    import_name: ?[]const u8 = null,
};

pub const Library = struct {
    step: *std.Build.Step.Compile,

    pub fn link(self: Library, other: *std.Build.Step.Compile, opts: Options) void {
        other.addIncludePath(.{ .cwd_relative = include_dir });
        other.linkLibrary(self.step);

        if (opts.import_name) |import_name|
            other.root_module.addAnonymousImport(
                import_name,
                .{ .root_source_file = .{ .path = package_path } },
            );
    }
};

pub fn create(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) Library {
    const ret = b.addStaticLibrary(.{
        .name = "z",
        .target = target,
        .optimize = optimize,
    });
    ret.linkLibC();
    ret.addCSourceFiles(.{
        .root = .{ .cwd_relative = root() },
        .files = srcs,
        .flags = &.{"-std=c89"},
    });

    return Library{ .step = ret };
}

const srcs = &.{
    "zlib/adler32.c",
    "zlib/compress.c",
    "zlib/crc32.c",
    "zlib/deflate.c",
    "zlib/gzclose.c",
    "zlib/gzlib.c",
    "zlib/gzread.c",
    "zlib/gzwrite.c",
    "zlib/inflate.c",
    "zlib/infback.c",
    "zlib/inftrees.c",
    "zlib/inffast.c",
    "zlib/trees.c",
    "zlib/uncompr.c",
    "zlib/zutil.c",
};
