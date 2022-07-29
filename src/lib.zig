const std = @import("std");
const zpp = @import("zpp");

const c = @cImport({
    @cInclude("zpp-snappy.h");
});

const SnappyError = error {
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
    if (!c.zpp_snappy_ss(true,
            data.ptr, data.len,
            out.ptr, &out.len,
            &buf_out, &capacity_out)) return SnappyError.Compress;
    
    if (buf_out != null) out.buf = buf_out[0..capacity_out];
}

pub fn decompressFSS(data: []const u8, out: *zpp.FlexStdString) !void {
    var buf_out: [*c]u8 = null;
    var capacity_out: usize = undefined;
    if (!c.zpp_snappy_ss(false,
            data.ptr, data.len,
            out.ptr, &out.len,
            &buf_out, &capacity_out)) return SnappyError.Decompress;
    
    if (buf_out != null) out.buf = buf_out[0..capacity_out];
}

/// Returns zero if not successful
pub fn getUncompressedLen(data: []const u8) usize {
    return c.zpp_snappy_get_uncompressed_len(
        data.ptr, data.len,
    );
}

fn verify(
    input: *std.ArrayList(u8),
    compressed: *std.ArrayList(u8),
    decompressed: *std.ArrayList(u8),
    compressedFSS: *zpp.FlexStdString,
    decompressedFSS: *zpp.FlexStdString,
) !void {
    try compress(input.items, compressed);
    try decompress(compressed.items, decompressed);
    try std.testing.expectEqualSlices(u8,
        input.items, decompressed.items,
    );
    try std.testing.expect(
        input.items.len == getUncompressedLen(compressed.items),
    );
    
    try compressFSS(input.items, compressedFSS);
    try std.testing.expectEqual(compressed.items.len, compressedFSS.len);
    try std.testing.expectEqualSlices(u8,
        compressed.items, compressedFSS.items(),
    );
    
    try decompressFSS(compressed.items, decompressedFSS);
    try std.testing.expectEqual(input.items.len, decompressedFSS.len);
    try std.testing.expectEqualSlices(u8,
        input.items, decompressedFSS.items(),
    );
    
    input.clearRetainingCapacity();
    compressed.clearRetainingCapacity();
    decompressed.clearRetainingCapacity();
    compressedFSS.len = 0;
    decompressedFSS.len = 0;
}

test "zig api" {
    const a = std.testing.allocator;
    
    var compressed = std.ArrayList(u8).init(a);
    defer compressed.deinit();
    var decompressed = std.ArrayList(u8).init(a);
    defer decompressed.deinit();
    
    var compressedFSS = zpp.initFlexStdString(1);
    defer compressedFSS.deinit();
    var decompressedFSS = zpp.initFlexStdString(1);
    defer decompressedFSS.deinit();
    
    var input = std.ArrayList(u8).init(a);
    defer input.deinit();
    
    try input.appendNTimes('a', 200);
    try input.appendNTimes('b', 200);
    try input.appendNTimes('c', 200);
    try input.appendNTimes('d', 200);
    try input.appendNTimes('e', 200);
    try verify(&input, &compressed, &decompressed, &compressedFSS, &decompressedFSS);
    
    try input.appendNTimes('f', 200);
    try input.appendNTimes('g', 200);
    try input.appendNTimes('h', 200);
    try input.appendNTimes('i', 200);
    try input.appendNTimes('j', 200);
    try verify(&input, &compressed, &decompressed, &compressedFSS, &decompressedFSS);
    
    std.debug.print("ok\n", .{});
}
