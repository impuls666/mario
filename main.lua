-- Main game file
local config = require("config")
local camera = require("camera")
local player = require("player")
local enemy = require("enemy")
local coin = require("coin")
local level = require("level")

function love.load()
    -- Set the window title and size
    love.window.setTitle(config.WINDOW_TITLE)
    love.window.setMode(config.WINDOW_WIDTH, config.WINDOW_HEIGHT)
    
    -- Initialize camera
    gameCamera = camera.new()
    
    -- Initialize Mario
    mario = player.new(100, config.GROUND_Y - config.PLAYER.HEIGHT)
    
    -- Initialize level manager
    levelManager = level.new()
    
    -- Game state
    score = 0
    gameTime = 0
    lives = 3
    
    -- Load first level
    currentLevelName = level.loadLevel(levelManager, 1)
end

function love.update(dt)
    if not mario.alive then
        return
    end
    
    gameTime = gameTime + dt
    
    -- Update Mario
    player.update(mario, dt, levelManager.platforms)
    
    -- Update enemies
    for _, goomba in ipairs(levelManager.enemies) do
        enemy.update(goomba, dt, levelManager.platforms)
        
        -- Check enemy collision with Mario
        local collided, defeated = enemy.checkPlayerCollision(goomba, mario, dt)
        if collided and defeated then
            score = score + config.SCORES.ENEMY_DEFEAT
        end
    end
    
    -- Check coin collection
    for _, coinObj in ipairs(levelManager.coins) do
        if coin.checkCollection(coinObj, mario) then
            score = score + config.SCORES.COIN_COLLECT
        end
    end
    
    -- Update level (check for completion)
    level.update(levelManager, mario, dt)
    
    -- Update camera
    camera.update(gameCamera, mario, config.LEVEL_WIDTH, config.WINDOW_WIDTH)
end

function love.draw()
    -- Apply camera transform
    camera.apply(gameCamera)
    
    -- Draw background (sky)
    love.graphics.setColor(config.COLORS.SKY)
    love.graphics.rectangle("fill", 0, 0, config.LEVEL_WIDTH, love.graphics.getHeight())
    
    -- Draw ground
    love.graphics.setColor(config.COLORS.GROUND)
    love.graphics.rectangle("fill", 0, config.GROUND_Y, config.LEVEL_WIDTH, love.graphics.getHeight() - config.GROUND_Y)
    
    -- Draw platforms
    love.graphics.setColor(config.COLORS.PLATFORM)
    for _, platform in ipairs(levelManager.platforms) do
        love.graphics.rectangle("fill", platform.x, platform.y, platform.width, platform.height)
    end
    
    -- Draw coins
    for _, coinObj in ipairs(levelManager.coins) do
        coin.draw(coinObj)
    end
    
    -- Draw enemies
    for _, goomba in ipairs(levelManager.enemies) do
        enemy.draw(goomba)
    end
    
    -- Draw goal flag
    level.drawGoal(levelManager)
    
    -- Draw Mario
    player.draw(mario)
    
    -- Reset camera transform
    camera.unapply()
    
    -- Draw UI (fixed position)
    love.graphics.setColor(config.COLORS.WHITE)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("Time: " .. math.floor(gameTime), 10, 30)
    love.graphics.print("Level: " .. level.getCurrentLevelName(levelManager), 10, 50)
    love.graphics.print("Lives: " .. lives, 10, 70)
    
    -- Draw FPS in upper right corner
    local fps = love.timer.getFPS()
    local fpsText = "FPS: " .. fps
    local fpsWidth = love.graphics.getFont():getWidth(fpsText)
    love.graphics.print(fpsText, love.graphics.getWidth() - fpsWidth - 10, 10)
    
    if not mario.alive then
        love.graphics.setColor(config.COLORS.MARIO_RED)
        love.graphics.print("GAME OVER! Press R to restart", love.graphics.getWidth()/2 - 100, love.graphics.getHeight()/2)
        love.graphics.print("Lives remaining: " .. (lives - 1), love.graphics.getWidth()/2 - 50, love.graphics.getHeight()/2 + 20)
    end
    
    -- Draw level complete screen
    level.drawLevelComplete(levelManager)
    
    -- Instructions
    love.graphics.setColor(config.COLORS.WHITE)
    love.graphics.print("Controls: A/D or Arrow Keys to move, Space/W/Up to jump", 10, love.graphics.getHeight() - 60)
    love.graphics.print("Jump on enemies to defeat them! Collect coins for points!", 10, love.graphics.getHeight() - 40)
    love.graphics.print("Reach the flag to complete the level!", 10, love.graphics.getHeight() - 20)
end

function love.keypressed(key)
    if key == "r" or key == "R" then
        if not mario.alive then
            -- Lose a life and restart current level
            lives = lives - 1
            if lives > 0 then
                mario.alive = true
                currentLevelName = level.loadLevel(levelManager, levelManager.currentLevel)
                mario.x = 100
                mario.y = config.GROUND_Y - mario.height
                mario.velX = 0
                mario.velY = 0
                mario.onGround = false
            else
                -- Game over - restart from level 1
                love.load()
            end
        else
            -- Restart entire game
            love.load()
        end
    end
    
    if key == "escape" then
        love.event.quit()
    end
    
    -- Debug: Skip to next level (remove in final version)
    if key == "n" and mario.alive then
        level.nextLevel(levelManager, mario)
        score = score + config.SCORES.LEVEL_COMPLETE
    end
end