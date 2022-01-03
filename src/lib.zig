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

pub fn compress(data: []const u8, out: *std.ArrayList(u8)) !bool {
    if (!zpp.initialized) return SnappyError.Zpp;
    return switch (c.zpp_snappy(true, @ptrCast([*c]const u8, data), data.len, out)) {
        0 => true,
        1 => SnappyError.Append,
        else => SnappyError.Compress,
    };
}

pub fn decompress(data: []const u8, out: *std.ArrayList(u8)) !bool {
    if (!zpp.initialized) return SnappyError.Zpp;
    return switch (c.zpp_snappy(false, @ptrCast([*c]const u8, data), data.len, out)) {
        0 => true,
        1 => SnappyError.Append,
        else => SnappyError.Decompress,
    };
}

fn verify(
    input: *std.ArrayList(u8),
    compressed: *std.ArrayList(u8),
    decompressed: *std.ArrayList(u8),
) !void {
    try std.testing.expect(try compress(input.items, compressed));
    try std.testing.expect(try decompress(input.items, decompressed));
    try std.testing.expectEqualSlices(u8, input.items, decompressed.items);
    
    input.clearRetainingCapacity();
    compressed.clearRetainingCapacity();
    decompressed.clearRetainingCapacity();
}

test "zig api" {
    const a = std.testing.allocator;
    
    var compressed = std.ArrayList(u8).init(a);
    defer compressed.deinit();
    
    var decompressed = std.ArrayList(u8).init(a);
    defer decompressed.deinit();
    
    var input = std.ArrayList(u8).init(a);
    defer input.deinit();
    
    try input.appendNTimes('a', 200);
    try input.appendNTimes('b', 200);
    try input.appendNTimes('c', 200);
    try input.appendNTimes('d', 200);
    try input.appendNTimes('e', 200);
    try verify(&input, &compressed, &decompressed);
    
    std.debug.print("zig api ok\n", .{});
}
