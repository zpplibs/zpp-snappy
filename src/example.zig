const std = @import("std");
const snappy = @import("lib.zig");

fn testDb(a: std.mem.Allocator, data: [:0]const u8) !void {
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
    
    try std.testing.expect(try snappy.compress(input.items, &compressed));
    try std.testing.expect(try snappy.decompress(input.items, &decompressed));
    try std.testing.expectEqualSlices(u8, input.items, decompressed.items);
    
    std.debug.print(
        "compressed from {} bytes to {} bytes for \"{s}\" repeated 100 times\n",
        .{ input.items.len, compressed.items.len, data },
    );
}

pub fn main() void {
    var allocator_instance = std.heap.GeneralPurposeAllocator(.{}){};
    const a = allocator_instance.allocator();
    const args = std.process.argsAlloc(a) catch return;
    defer a.free(args);
    
    const path = if (args.len > 1) args[1] else "1234567890";
    testDb(a, path) catch |err| {
        std.debug.print("error: ${i}\n", .{err});
    };
}