const rl = @import("raylib");

/// Represents the state of the game world.
pub const World = struct {
    /// Initiaizes and returns a world.
    pub fn init() World {
        return World{};
    }

    /// Deallocates all memory related to a world.
    pub fn deinit(self: *World) void {
        _ = self;
    }

    /// Updates the state of a world.
    pub fn update(self: *World) void {
        _ = self;
    }

    /// Draws the world.
    pub fn draw(self: *const World, display_font: rl.Font) void {
        _ = self;
        rl.drawTextEx(display_font, "Text testings... Get comfy!", rl.Vector2.init(190, 220), 30, 0, rl.Color.white);
    }
};
