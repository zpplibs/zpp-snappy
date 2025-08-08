const std = @import("std");
const zpp = @import("zpp");

const c = @cImport({
    @cInclude("zpp-snappy.h");
});

const SnappyError = error{
    Append,
    Compress,
    Decompress,
    Zpp,
};

pub fn compress(data: []const u8, out: *std.ArrayList(u8)) !void {
    if (!zpp.initialized) return SnappyError.Zpp;
    switch (c.zpp_snappy(true, data.ptr, data.len, out)) {
        0 => return,
        1 => return SnappyError.Append,
        else => return SnappyError.Compress,
    }
}

pub fn decompress(data: []const u8, out: *std.ArrayList(u8)) !void {
    if (!zpp.initialized) return SnappyError.Zpp;
    switch (c.zpp_snappy(false, data.ptr, data.len, out)) {
        0 => return,
        1 => return SnappyError.Append,
        else => return SnappyError.Decompress,
    }
}

pub fn compressFSS(data: []const u8, out: *zpp.FlexStdString) !void {
    var buf_out: [*c]u8 = null;
    var capacity_out: usize = undefined;
    if (!c.zpp_snappy_ss(
        true,
        data.ptr,
        data.len,
        out.ptr,
        &out.len,
        &buf_out,
        &capacity_out,
    )) return SnappyError.Compress;

    if (buf_out != null) out.buf = buf_out[0..capacity_out];
}

pub fn decompressFSS(data: []const u8, out: *zpp.FlexStdString) !void {
    var buf_out: [*c]u8 = null;
    var capacity_out: usize = undefined;
    if (!c.zpp_snappy_ss(
        false,
        data.ptr,
        data.len,
        out.ptr,
        &out.len,
        &buf_out,
        &capacity_out,
    )) return SnappyError.Decompress;

    if (buf_out != null) out.buf = buf_out[0..capacity_out];
}

/// Returns zero if not successful
pub fn getUncompressedLen(data: []const u8) usize {
    return c.zpp_snappy_get_uncompressed_len(
        data.ptr,
        data.len,
    );
}
