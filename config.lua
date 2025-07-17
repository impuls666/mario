-- Game configuration and constants
local config = {}

-- Window settings
config.WINDOW_WIDTH = 800
config.WINDOW_HEIGHT = 600
config.WINDOW_TITLE = "Princess Adventure 2D"

-- Camera/Zoom settings
config.ZOOM_FACTOR = 2.0  -- 2.0 = 200% zoom (everything appears twice as big)

-- Audio settings
config.AUDIO = {
    MUSIC_VOLUME = 0.7,
    MUSIC_ENABLED = true
}

-- Physics constants
config.GRAVITY = 1500
config.GROUND_Y = 500
config.TILE_SIZE = 32

-- Player settings (collision box - visual sprite will be scaled by zoom)
config.PLAYER = {
    WIDTH = 24,
    HEIGHT = 32,
    SPEED = 200,
    JUMP_POWER = 600
}

-- Enemy settings (now same size as player!)
config.ENEMY = {
    WIDTH = 24,   -- Same as player width
    HEIGHT = 32,  -- Same as player height
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
    SKY = {0.7, 0.9, 1},           -- Lighter blue for princess theme
    GROUND = {0.9, 0.7, 0.9},      -- Pink-ish ground
    PLATFORM = {0.8, 0.6, 0.8},   -- Purple platforms
    MARIO_RED = {1, 0.75, 0.8},    -- Princess pink
    MARIO_SKIN = {1, 0.9, 0.8},    -- Skin tone
    ENEMY_BROWN = {0.6, 0.3, 0},   -- Fallback skeleton color
    SKELETON_BONE = {0.9, 0.9, 0.8}, -- Bone white for skeleton
    COIN_YELLOW = {1, 1, 0},
    WHITE = {1, 1, 1},
    BLACK = {0, 0, 0},
    GREEN = {0, 1, 0},
    YELLOW = {1, 1, 0}
}

return config 