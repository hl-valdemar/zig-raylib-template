const std = @import("std");
const rl = @import("raylib");
const world = @import("world/mod.zig");

const World = world.World;

pub const Message = union(enum) {
    SetDebugView: bool,
    SetPaused: bool,
    None,
};

pub const GameOptions = struct {
    title: [*:0]const u8,
    screen_size: rl.Vector2,
    cap_fps: bool,
    view_debug: bool,

    pub fn default() GameOptions {
        return GameOptions{
            .title = "Zig/Raylib Template - Change your title!",
            .screen_size = rl.Vector2.init(8 * 150, 8 * 100),
            .cap_fps = false,
            .view_debug = false,
        };
    }
};

/// Represents the state of a game.
pub const Game = struct {
    // Pertaining to the window.
    title: [*:0]const u8,
    screen_width: i32,
    screen_height: i32,

    // Miscellaneous options.
    font: rl.Font,
    cap_fps: bool,
    view_debug: bool,
    is_paused: bool,

    // The game world.
    world: World,

    /// Initialize a game and return it.
    pub fn init(options: GameOptions) Game {
        const game = Game{
            // ---------------------
            .title = options.title,
            .screen_width = @as(i32, @intFromFloat(options.screen_size.x)),
            .screen_height = @as(i32, @intFromFloat(options.screen_size.y)),

            // ---------------------
            .font = undefined,
            .cap_fps = options.cap_fps,
            .view_debug = options.view_debug,
            .is_paused = false,

            // ---------------------
            .world = World.init(),
        };

        return game;
    }

    /// Deallocates all memory related to a game.
    pub fn deinit(self: *Game) void {
        self.world.deinit();
        rl.unloadFont(self.font);
    }

    /// Runs a game.
    pub fn run(self: *Game) void {
        // Setup
        rl.initWindow(self.screen_width, self.screen_height, self.title);
        defer rl.closeWindow();

        rl.setWindowState(rl.ConfigFlags{ .window_resizable = true });

        // Requries the window (or rather, the render context) to be open
        // before loading the font.
        self.font = rl.loadFont("assets/fonts/monogram-extended.ttf");

        if (self.cap_fps) {
            rl.setTargetFPS(60);
        }

        // Game loop
        while (!rl.windowShouldClose()) {
            self.handleWindowResize();

            const message = self.handleInput();
            self.update(message);

            self.draw();
        }
    }

    /// Updates the state of a game.
    fn update(self: *Game, message: Message) void {
        // Handle messages/events.
        switch (message) {
            .SetDebugView => |is_visible| self.view_debug = is_visible,
            .SetPaused => |is_paused| self.is_paused = is_paused,
            .None => {}, // Do nothing...
        }

        // Update the world.
        self.world.update();
    }

    fn handleWindowResize(self: *Game) void {
        self.screen_width = rl.getScreenWidth();
        self.screen_height = rl.getScreenHeight();
    }

    fn handleInput(self: *Game) Message {
        if (rl.isKeyPressed(rl.KeyboardKey.key_equal)) {
            return Message{ .SetDebugView = !self.view_debug };
        }

        if (rl.isKeyPressed(rl.KeyboardKey.key_p)) {
            return Message{ .SetPaused = !self.is_paused };
        }

        return Message.None;
    }

    /// Draws the game.
    fn draw(self: *const Game) void {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        self.world.draw(self.font);

        if (self.is_paused) {
            self.drawPause();
        }

        if (self.view_debug) {
            self.drawDebug();
        }
    }

    pub fn drawPause(self: *const Game) void {
        const paused_text = "Paused";
        const font_size = 40;
        const paused_text_size = rl.measureTextEx(
            self.font,
            paused_text,
            font_size,
            0,
        );
        const paused_text_pos_x = @as(f32, @floatFromInt(self.screen_width)) - paused_text_size.x - font_size;
        const paused_text_pos_y = font_size;
        const paused_text_pos = rl.Vector2.init(
            paused_text_pos_x,
            paused_text_pos_y,
        );

        rl.drawTextEx(
            self.font,
            paused_text,
            paused_text_pos,
            font_size,
            0,
            rl.Color.white,
        );
    }

    pub fn drawDebug(self: *const Game) void {
        self.drawFps();
    }

    pub fn drawFps(self: *const Game) void {
        const fps = rl.getFPS();
        var fps_buffer: [20]u8 = undefined;
        const fps_text = std.fmt.bufPrintZ(&fps_buffer, "{d} fps", .{fps}) catch {
            std.debug.print("Error allocating fps text\n", .{});
            return;
        };

        const millis = rl.getFrameTime();
        var millis_buffer: [20]u8 = undefined;
        const millis_text = std.fmt.bufPrintZ(&millis_buffer, "{d:.5} millis", .{millis}) catch {
            std.debug.print("Error allocating millis text\n", .{});
            return;
        };

        const pos = rl.Vector2.init(10, 10);
        const font_size = 25;

        rl.drawTextEx(self.font, fps_text.ptr, pos, font_size, 0, rl.Color.white);
        rl.drawTextEx(self.font, millis_text.ptr, rl.Vector2.init(pos.x, pos.y + font_size + 1), 25, 0, rl.Color.white);
    }
};
