-- Main game file
local config = require("config")
local camera = require("camera")
local player = require("player")
local enemy = require("enemy")
local coin = require("coin")

function love.load()
    -- Set the window title and size
    love.window.setTitle(config.WINDOW_TITLE)
    love.window.setMode(config.WINDOW_WIDTH, config.WINDOW_HEIGHT)
    
    -- Initialize camera
    gameCamera = camera.new()
    
    -- Initialize Mario
    mario = player.new(100, config.GROUND_Y - config.PLAYER.HEIGHT)
    
    -- Game state
    score = 0
    gameTime = 0
    
    -- Create platforms
    platforms = {
        {x = 300, y = 400, width = 128, height = 16},
        {x = 500, y = 350, width = 96, height = 16},
        {x = 700, y = 300, width = 128, height = 16},
        {x = 900, y = 250, width = 96, height = 16},
        {x = 1200, y = 400, width = 160, height = 16},
        {x = 1450, y = 350, width = 96, height = 16}
    }
    
    -- Create enemies
    enemies = {
        enemy.new(400, config.GROUND_Y - config.ENEMY.HEIGHT, -50),
        enemy.new(600, config.GROUND_Y - config.ENEMY.HEIGHT, -30),
        enemy.new(800, config.GROUND_Y - config.ENEMY.HEIGHT, -40),
        enemy.new(1100, config.GROUND_Y - config.ENEMY.HEIGHT, -35),
        enemy.new(1300, config.GROUND_Y - config.ENEMY.HEIGHT, -45)
    }
    
    -- Create coins
    coins = {
        coin.new(350, 350),
        coin.new(550, 300),
        coin.new(750, 250),
        coin.new(950, 200),
        coin.new(1250, 350),
        coin.new(1500, 300)
    }
end

function love.update(dt)
    if not mario.alive then
        return
    end
    
    gameTime = gameTime + dt
    
    -- Update Mario
    player.update(mario, dt, platforms)
    
    -- Update enemies
    for _, goomba in ipairs(enemies) do
        enemy.update(goomba, dt, platforms)
        
        -- Check enemy collision with Mario (now passing dt)
        local collided, defeated = enemy.checkPlayerCollision(goomba, mario, dt)
        if collided and defeated then
            score = score + 100
        end
    end
    
    -- Check coin collection
    for _, coinObj in ipairs(coins) do
        if coin.checkCollection(coinObj, mario) then
            score = score + config.COIN.VALUE
        end
    end
    
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
    for _, platform in ipairs(platforms) do
        love.graphics.rectangle("fill", platform.x, platform.y, platform.width, platform.height)
    end
    
    -- Draw coins
    for _, coinObj in ipairs(coins) do
        coin.draw(coinObj)
    end
    
    -- Draw enemies
    for _, goomba in ipairs(enemies) do
        enemy.draw(goomba)
    end
    
    -- Draw Mario
    player.draw(mario)
    
    -- Reset camera transform
    camera.unapply()
    
    -- Draw UI (fixed position)
    love.graphics.setColor(config.COLORS.WHITE)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("Time: " .. math.floor(gameTime), 10, 30)
    
    if not mario.alive then
        love.graphics.setColor(config.COLORS.MARIO_RED)
        love.graphics.print("GAME OVER! Press R to restart", love.graphics.getWidth()/2 - 100, love.graphics.getHeight()/2)
    end
    
    -- Instructions
    love.graphics.setColor(config.COLORS.WHITE)
    love.graphics.print("Controls: A/D or Arrow Keys to move, Space/W/Up to jump", 10, love.graphics.getHeight() - 40)
    love.graphics.print("Jump on enemies to defeat them! Collect coins for points!", 10, love.graphics.getHeight() - 20)
end

function love.keypressed(key)
    if key == "r" and not mario.alive then
        -- Restart game
        love.load()
    end
    
    if key == "escape" then
        love.event.quit()
    end
end