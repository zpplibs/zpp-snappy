const std = @import("std");
const zpp = @import("zpp");
const snappy = @import("zpp_snappy");

fn verify(
    input: *std.ArrayList(u8),
    compressed: *std.ArrayList(u8),
    decompressed: *std.ArrayList(u8),
    compressedFSS: *zpp.FlexStdString,
    decompressedFSS: *zpp.FlexStdString,
) !void {
    try snappy.compress(input.items, compressed);
    try snappy.decompress(compressed.items, decompressed);
    try std.testing.expectEqualSlices(
        u8,
        input.items,
        decompressed.items,
    );
    try std.testing.expect(
        input.items.len == snappy.getUncompressedLen(compressed.items),
    );

    try snappy.compressFSS(input.items, compressedFSS);
    try std.testing.expectEqual(compressed.items.len, compressedFSS.len);
    try std.testing.expectEqualSlices(
        u8,
        compressed.items,
        compressedFSS.items(),
    );

    try snappy.decompressFSS(compressed.items, decompressedFSS);
    try std.testing.expectEqual(input.items.len, decompressedFSS.len);
    try std.testing.expectEqualSlices(
        u8,
        input.items,
        decompressedFSS.items(),
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
