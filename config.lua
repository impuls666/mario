-- Game configuration and constants
local config = {}

-- Window settings
config.WINDOW_WIDTH = 800
config.WINDOW_HEIGHT = 600
config.WINDOW_TITLE = "Super Mario 2D"

-- Physics constants
config.GRAVITY = 1500
config.GROUND_Y = 500
config.TILE_SIZE = 32

-- Player settings
config.PLAYER = {
    WIDTH = 24,
    HEIGHT = 32,
    SPEED = 200,
    JUMP_POWER = 600
}

-- Enemy settings
config.ENEMY = {
    WIDTH = 16,
    HEIGHT = 16,
    SPEED_MIN = 30,
    SPEED_MAX = 50
}

-- Coin settings
config.COIN = {
    WIDTH = 12,
    HEIGHT = 12,
    VALUE = 200
}

-- Level settings (will be set dynamically by level manager)
config.LEVEL_WIDTH = 1200
config.GOAL_X = 1000

-- Scoring
config.SCORES = {
    ENEMY_DEFEAT = 100,
    COIN_COLLECT = 200,
    LEVEL_COMPLETE = 1000
}

-- Colors
config.COLORS = {
    SKY = {0.5, 0.8, 1},
    GROUND = {0.2, 0.8, 0.2},
    PLATFORM = {0.6, 0.4, 0.2},
    MARIO_RED = {1, 0, 0},
    MARIO_SKIN = {1, 0.8, 0.6},
    ENEMY_BROWN = {0.6, 0.3, 0},
    COIN_YELLOW = {1, 1, 0},
    WHITE = {1, 1, 1},
    BLACK = {0, 0, 0},
    GREEN = {0, 1, 0},
    YELLOW = {1, 1, 0}
}

return config 