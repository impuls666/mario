-- Level management system
local config = require("config")
local enemy = require("enemy")
local coin = require("coin")

local level = {}

-- Level definitions
local levels = {
    -- Level 1: Tutorial
    {
        name = "World 1-1",
        platforms = {
            {x = 300, y = 400, width = 128, height = 16},
            {x = 500, y = 350, width = 96, height = 16},
            {x = 700, y = 300, width = 128, height = 16}
        },
        enemies = {
            {x = 400, speed = -30},
            {x = 800, speed = -25}
        },
        coins = {
            {x = 350, y = 350},
            {x = 550, y = 300},
            {x = 750, y = 250}
        },
        goalX = 1000,
        levelWidth = 1200
    },
    
    -- Level 2: More platforms
    {
        name = "World 1-2",
        platforms = {
            {x = 200, y = 450, width = 96, height = 16},
            {x = 400, y = 400, width = 64, height = 16},
            {x = 550, y = 350, width = 96, height = 16},
            {x = 750, y = 300, width = 64, height = 16},
            {x = 900, y = 250, width = 128, height = 16},
            {x = 1150, y = 350, width = 96, height = 16}
        },
        enemies = {
            {x = 300, speed = -40},
            {x = 600, speed = -35},
            {x = 950, speed = -45},
            {x = 1200, speed = -30}
        },
        coins = {
            {x = 250, y = 400},
            {x = 450, y = 350},
            {x = 600, y = 300},
            {x = 800, y = 250},
            {x = 950, y = 200},
            {x = 1200, y = 300}
        },
        goalX = 1400,
        levelWidth = 1600
    },
    
    -- Level 3: Challenging jumps
    {
        name = "World 1-3",
        platforms = {
            {x = 250, y = 400, width = 64, height = 16},
            {x = 400, y = 320, width = 64, height = 16},
            {x = 600, y = 380, width = 64, height = 16},
            {x = 800, y = 280, width = 96, height = 16},
            {x = 1000, y = 350, width = 64, height = 16},
            {x = 1200, y = 250, width = 128, height = 16},
            {x = 1450, y = 400, width = 96, height = 16}
        },
        enemies = {
            {x = 350, speed = -50},
            {x = 500, speed = -40},
            {x = 750, speed = -45},
            {x = 1050, speed = -35},
            {x = 1350, speed = -55}
        },
        coins = {
            {x = 300, y = 350},
            {x = 450, y = 270},
            {x = 650, y = 330},
            {x = 850, y = 230},
            {x = 1050, y = 300},
            {x = 1250, y = 200},
            {x = 1500, y = 350}
        },
        goalX = 1700,
        levelWidth = 1900
    },
    
    -- Level 4: Enemy gauntlet
    {
        name = "World 1-4",
        platforms = {
            {x = 300, y = 450, width = 128, height = 16},
            {x = 500, y = 400, width = 96, height = 16},
            {x = 700, y = 450, width = 128, height = 16},
            {x = 950, y = 350, width = 160, height = 16},
            {x = 1200, y = 400, width = 128, height = 16},
            {x = 1450, y = 300, width = 96, height = 16}
        },
        enemies = {
            {x = 350, speed = -40},
            {x = 450, speed = -35},
            {x = 550, speed = -45},
            {x = 750, speed = -50},
            {x = 850, speed = -30},
            {x = 1000, speed = -55},
            {x = 1150, speed = -40},
            {x = 1300, speed = -45}
        },
        coins = {
            {x = 350, y = 400},
            {x = 550, y = 350},
            {x = 750, y = 400},
            {x = 1000, y = 300},
            {x = 1250, y = 350},
            {x = 1500, y = 250}
        },
        goalX = 1800,
        levelWidth = 2000
    }
}

function level.new()
    return {
        currentLevel = 1,
        totalLevels = #levels,
        levelComplete = false,
        showLevelComplete = false,
        levelCompleteTimer = 0,
        platforms = {},
        enemies = {},
        coins = {}
    }
end

function level.loadLevel(levelManager, levelNumber)
    if levelNumber > #levels then
        levelNumber = #levels -- Cap at max level
    end
    
    local levelData = levels[levelNumber]
    levelManager.currentLevel = levelNumber
    levelManager.levelComplete = false
    levelManager.showLevelComplete = false
    levelManager.levelCompleteTimer = 0
    
    -- Load platforms
    levelManager.platforms = {}
    for _, platform in ipairs(levelData.platforms) do
        table.insert(levelManager.platforms, {
            x = platform.x,
            y = platform.y,
            width = platform.width,
            height = platform.height
        })
    end
    
    -- Load enemies
    levelManager.enemies = {}
    for _, enemyData in ipairs(levelData.enemies) do
        table.insert(levelManager.enemies, enemy.new(
            enemyData.x, 
            config.GROUND_Y - config.ENEMY.HEIGHT, 
            enemyData.speed
        ))
    end
    
    -- Load coins
    levelManager.coins = {}
    for _, coinData in ipairs(levelData.coins) do
        table.insert(levelManager.coins, coin.new(coinData.x, coinData.y))
    end
    
    -- Set level bounds
    config.LEVEL_WIDTH = levelData.levelWidth
    config.GOAL_X = levelData.goalX
    
    return levelData.name
end

function level.update(levelManager, mario, dt)
    -- Check if Mario reached the goal
    if mario.x >= config.GOAL_X and not levelManager.levelComplete then
        levelManager.levelComplete = true
        levelManager.showLevelComplete = true
        levelManager.levelCompleteTimer = 0
    end
    
    -- Handle level complete timer
    if levelManager.showLevelComplete then
        levelManager.levelCompleteTimer = levelManager.levelCompleteTimer + dt
        
        -- Auto advance after 3 seconds or if player presses space
        if levelManager.levelCompleteTimer >= 3.0 or love.keyboard.isDown("space") then
            level.nextLevel(levelManager, mario)
        end
    end
end

function level.nextLevel(levelManager, mario)
    if levelManager.currentLevel < levelManager.totalLevels then
        levelManager.currentLevel = levelManager.currentLevel + 1
        level.loadLevel(levelManager, levelManager.currentLevel)
        
        -- Reset Mario position
        mario.x = 100
        mario.y = config.GROUND_Y - mario.height
        mario.velX = 0
        mario.velY = 0
        mario.onGround = false
        mario.alive = true
    else
        -- Game complete!
        levelManager.showLevelComplete = false
        -- Could add game complete screen here
    end
end

function level.getCurrentLevelName(levelManager)
    if levelManager.currentLevel <= #levels then
        return levels[levelManager.currentLevel].name
    else
        return "Game Complete!"
    end
end

function level.drawGoal(levelManager)
    if config.GOAL_X then
        -- Draw goal flag
        love.graphics.setColor(0, 1, 0) -- Green
        love.graphics.rectangle("fill", config.GOAL_X, config.GROUND_Y - 100, 10, 100)
        
        -- Draw flag
        love.graphics.setColor(1, 1, 0) -- Yellow
        love.graphics.rectangle("fill", config.GOAL_X + 10, config.GROUND_Y - 100, 30, 20)
        
        -- Flag pole top
        love.graphics.setColor(1, 1, 1) -- White
        love.graphics.circle("fill", config.GOAL_X + 5, config.GROUND_Y - 105, 5)
    end
end

function level.drawLevelComplete(levelManager)
    if levelManager.showLevelComplete then
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()
        
        -- Background overlay
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
        
        -- Level complete text
        love.graphics.setColor(1, 1, 1)
        local completeText = "LEVEL COMPLETE!"
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(completeText)
        love.graphics.print(completeText, screenWidth/2 - textWidth/2, screenHeight/2 - 40)
        
        if levelManager.currentLevel < levelManager.totalLevels then
            local nextText = "Press SPACE to continue or wait 3 seconds"
            local nextWidth = font:getWidth(nextText)
            love.graphics.print(nextText, screenWidth/2 - nextWidth/2, screenHeight/2 + 10)
        else
            local gameCompleteText = "CONGRATULATIONS! YOU BEAT ALL LEVELS!"
            local gameWidth = font:getWidth(gameCompleteText)
            love.graphics.print(gameCompleteText, screenWidth/2 - gameWidth/2, screenHeight/2 + 10)
        end
    end
end

return level 