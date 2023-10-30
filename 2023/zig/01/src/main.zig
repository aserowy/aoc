const std = @import("std");
const ArrayList = std.ArrayList;

const Allocator = std.mem.Allocator;
const Elf = u32;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var elfs = try mapFileContentToElfs(allocator, "input.txt");

    var calMax: u32 = 0;
    std.sort.heap(u32, elfs.items, {}, std.sort.asc(u32));

    for (elfs.items[(elfs.items.len - 3)..]) |value| {
        std.debug.print("top 3 max cal: {}\n", .{value});
        calMax += value;
    }

    elfs.deinit();

    std.debug.print("max cal: {}\n", .{calMax});
}

fn mapFileContentToElfs(allocator: Allocator, path: []const u8) !ArrayList(Elf) {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var reader = file.reader();

    var buf: [1024]u8 = undefined;
    var output = std.io.fixedBufferStream(&buf);

    const writer = output.writer();

    var result = ArrayList(Elf).init(allocator);
    var elf: Elf = 0;
    try result.append(elf);

    while (true) {
        reader.streamUntilDelimiter(writer, '\n', 1024) catch |err| switch (err) {
            error.EndOfStream => {
                break;
            },
            else => |e| return e,
        };

        var line = output.getWritten();

        std.debug.print("line: {s}\n", .{line});

        if (line.len > 0) {
            elf += try std.fmt.parseUnsigned(u32, line, 10);

            std.debug.print("calorie: {}\n", .{elf});
        } else {
            try result.append(elf);

            elf = 0;
        }

        output.reset();
    }

    return result;
}
