const std = @import("std");

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var games = try mapFileContentToRpsRounds(allocator, "input.txt");
    defer games.deinit();

    var score: u16 = 0;
    while (games.popOrNull()) |game| {
        score += try calculateScore(game);
    }

    std.debug.print("score sum: {}", .{score});
}

fn calculateScore(game: []const u8) !u8 {
    return try calculateScoreByGameEnding(game) + try calculateScoreByChoice(game);
}

fn calculateScoreByChoice(game: []const u8) !u8 {
    if (std.mem.eql(u8, game, &[_]u8{ 'A', ' ', 'X' })) {
        return 3;
    }

    if (std.mem.eql(u8, game, &[_]u8{ 'A', ' ', 'Y' })) {
        return 1;
    }

    if (std.mem.eql(u8, game, &[_]u8{ 'A', ' ', 'Z' })) {
        return 2;
    }

    if (std.mem.eql(u8, game, &[_]u8{ 'B', ' ', 'X' })) {
        return 1;
    }

    if (std.mem.eql(u8, game, &[_]u8{ 'B', ' ', 'Y' })) {
        return 2;
    }

    if (std.mem.eql(u8, game, &[_]u8{ 'B', ' ', 'Z' })) {
        return 3;
    }

    if (std.mem.eql(u8, game, &[_]u8{ 'C', ' ', 'X' })) {
        return 2;
    }

    if (std.mem.eql(u8, game, &[_]u8{ 'C', ' ', 'Y' })) {
        return 3;
    }

    if (std.mem.eql(u8, game, &[_]u8{ 'C', ' ', 'Z' })) {
        return 1;
    }

    return error.Unreachable;
}

fn calculateScoreByGameEnding(game: []const u8) !u8 {
    if (std.mem.count(u8, game, "X") == 1) {
        return 0;
    }

    if (std.mem.count(u8, game, "Y") == 1) {
        return 3;
    }

    if (std.mem.count(u8, game, "Z") == 1) {
        return 6;
    }

    return error.Unreachable;
}

fn mapFileContentToRpsRounds(allocator: Allocator, path: []const u8) !ArrayList([]const u8) {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var reader = file.reader();

    var buf: [1024]u8 = undefined;
    var output = std.io.fixedBufferStream(&buf);

    const writer = output.writer();

    var result = ArrayList([]const u8).init(allocator);

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
            const copy = try allocator.dupe(u8, line);

            std.debug.print("copy: {s}\n", .{copy});

            try result.append(copy);
        }

        output.reset();
    }

    return result;
}
