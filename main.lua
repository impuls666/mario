-- Main game file with limited vertical camera following
local config = require("config")
local camera = require("camera")
local player = require("player")
local enemy = require("enemy")
local coin = require("coin")
local level = require("level")
local sprites = require("sprites")

-- Game state variables
local gameCamera
local mario
local levelManager
local score
local gameTime
local lives
local currentLevelName
local gameInitialized = false

function love.load()
    -- Set the window title and size
    love.window.setTitle(config.WINDOW_TITLE)
    love.window.setMode(config.WINDOW_WIDTH, config.WINDOW_HEIGHT)
    
    -- Load sprites
    print("Loading princess sprites...")
    sprites.load()
    
    -- Show simple main menu
    showMainMenu()
end

function showMainMenu()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    love.graphics.setColor(0.3, 0.1, 0.3) -- Purple background
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
    
    love.graphics.setColor(1, 0.75, 0.9) -- Pink title
    love.graphics.print("PRINCESS ADVENTURE 2D", screenWidth/2 - 120, 200)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Press SPACE to start game", screenWidth/2 - 100, 300)
    love.graphics.print("Press ESCAPE to exit", screenWidth/2 - 80, 330)
    
    -- Show sprite status and controls info
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print("Princess sprites loaded from princess/ folder", screenWidth/2 - 140, 380)
    love.graphics.print("Camera follows vertically between Y: 210-250", screenWidth/2 - 120, 400)
    
    love.graphics.present()
end

function initializeGame()
    -- Initialize camera with limited vertical range
    gameCamera = camera.new()
    gameCamera.zoom = config.ZOOM_FACTOR
    -- Set the Y range from 210 to 250
    camera.setRange(gameCamera, 210, 250)
    
    -- Initialize Princess
    mario = player.new(100, config.GROUND_Y - config.PLAYER.HEIGHT)
    
    -- Initialize level manager
    levelManager = level.new()
    
    -- Game state
    score = 0
    gameTime = 0
    lives = 3
    
    -- Load first level
    currentLevelName = level.loadLevel(levelManager, 1)
    
    gameInitialized = true
end

function love.update(dt)
    if gameInitialized then
        if not mario.alive then
            return
        end
        
        gameTime = gameTime + dt
        
        -- Update Princess
        player.update(mario, dt, levelManager.platforms)
        
        -- Update enemies
        for _, goomba in ipairs(levelManager.enemies) do
            enemy.update(goomba, dt, levelManager.platforms)
            
            -- Check enemy collision with Princess
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
        
        -- Update camera (limited vertical following)
        camera.update(gameCamera, mario, config.LEVEL_WIDTH, config.WINDOW_WIDTH, config.WINDOW_HEIGHT)
    end
end

function love.draw()
    if not gameInitialized then
        showMainMenu()
        return
    end
    
    -- Apply camera transform (limited vertical following)
    camera.apply(gameCamera)
    
    -- Draw background (sky) - make it larger to account for camera movement
    love.graphics.setColor(config.COLORS.SKY)
    love.graphics.rectangle("fill", -200, -200, config.LEVEL_WIDTH + 400, love.graphics.getHeight() + 400)
    
    -- Draw ground - princess theme
    love.graphics.setColor(config.COLORS.GROUND)
    love.graphics.rectangle("fill", 0, config.GROUND_Y, config.LEVEL_WIDTH, love.graphics.getHeight() - config.GROUND_Y + 200)
    
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
    
    -- Draw Princess
    player.draw(mario)
    
    -- Reset camera transform
    camera.unapply()
    
    -- Draw UI (fixed position - NOT affected by zoom)
    love.graphics.setColor(config.COLORS.WHITE)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("Time: " .. math.floor(gameTime), 10, 30)
    love.graphics.print("Level: " .. level.getCurrentLevelName(levelManager), 10, 50)
    love.graphics.print("Lives: " .. lives, 10, 70)
    love.graphics.print("Zoom: " .. string.format("%.1f", gameCamera.zoom) .. "x", 10, 90)
    love.graphics.print("Camera Y: " .. string.format("%.0f", gameCamera.y) .. " (range: " .. gameCamera.minY .. "-" .. gameCamera.maxY .. ")", 10, 110)
    
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
    if mario.alive then
        love.graphics.setColor(config.COLORS.WHITE)
        love.graphics.print("Controls: A/D move, Space jump", 10, love.graphics.getHeight() - 80)
        love.graphics.print("Zoom: +/- keys", 10, love.graphics.getHeight() - 60)
        love.graphics.print("Camera range: Page Up/Down to adjust", 10, love.graphics.getHeight() - 40)
        love.graphics.print("Reach the flag to complete the level!", 10, love.graphics.getHeight() - 20)
    end
end

function love.keypressed(key)
    if not gameInitialized then
        if key == "space" then
            initializeGame()
        elseif key == "escape" then
            love.event.quit()
        end
        return
    end
    
    -- Zoom controls
    if key == "=" or key == "+" then
        gameCamera.zoom = math.min(gameCamera.zoom + 0.25, 4.0) -- Max zoom 4x
        print("Zoom: " .. gameCamera.zoom .. "x")
    elseif key == "-" or key == "_" then
        gameCamera.zoom = math.max(gameCamera.zoom - 0.25, 0.5) -- Min zoom 0.5x
        print("Zoom: " .. gameCamera.zoom .. "x")
    end
    
    -- Camera range adjustment controls
    if key == "pageup" then
        camera.adjustRange(gameCamera, -10, -10) -- Move entire range up
        print("Camera range: " .. gameCamera.minY .. " to " .. gameCamera.maxY)
    elseif key == "pagedown" then
        camera.adjustRange(gameCamera, 10, 10) -- Move entire range down
        print("Camera range: " .. gameCamera.minY .. " to " .. gameCamera.maxY)
    end
    
    -- Preset camera ranges
    if key == "1" then
        camera.setRange(gameCamera, 180, 220) -- Higher range (more sky)
        print("Camera preset: High range (180-220)")
    elseif key == "2" then
        camera.setRange(gameCamera, 210, 250) -- Default range
        print("Camera preset: Normal range (210-250)")
    elseif key == "3" then
        camera.setRange(gameCamera, 240, 280) -- Lower range (more ground focus)
        print("Camera preset: Low range (240-280)")
    end
    
    -- Reset camera range
    if key == "home" then
        camera.setRange(gameCamera, 210, 250) -- Reset to default range
        print("Camera range reset to: 210-250")
    end
    
    if key == "r" or key == "R" then
        if not mario.alive then
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
                gameInitialized = false
            end
        else
            initializeGame()
        end
    end
    
    if key == "escape" then
        love.event.quit()
    end
    
    -- Debug: Skip to next level
    if key == "n" and mario and mario.alive then
        level.nextLevel(levelManager, mario)
        score = score + config.SCORES.LEVEL_COMPLETE
    end
end