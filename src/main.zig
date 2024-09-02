const rl = @import("raylib");
const game = @import("game.zig");

const Game = game.Game;
const GameOptions = game.GameOptions;

pub fn main() void {
    var g = Game.init(GameOptions.default());
    g.run();
}
