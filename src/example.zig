const std = @import("std");
const snappy = @import("zpp_snappy");

fn run(a: std.mem.Allocator, data: [:0]const u8) !void {
    var compressed = std.ArrayList(u8).init(a);
    defer compressed.deinit();

    var decompressed = std.ArrayList(u8).init(a);
    defer decompressed.deinit();

    var input = std.ArrayList(u8).init(a);
    defer input.deinit();

    var i: usize = 0;
    while (i < 100) {
        try input.appendSlice(data);
        i += 1;
    }

    try snappy.compress(input.items, &compressed);
    try snappy.decompress(compressed.items, &decompressed);
    try std.testing.expectEqualSlices(u8, input.items, decompressed.items);

    std.debug.print(
        "compressed from {} bytes to {} bytes for \"{s}\" repeated 100 times\n",
        .{ input.items.len, compressed.items.len, data },
    );
}

pub fn main() !void {
    const a = std.heap.raw_c_allocator;
    const args = try std.process.argsAlloc(a);
    defer a.free(args);

    const data = if (args.len > 1) args[1] else "abcd1234#!";
    try run(a, data);
}
