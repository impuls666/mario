-- Main game file with mobile support
local config = require("config")
local camera = require("camera")
local player = require("player")
local enemy = require("enemy")
local coin = require("coin")
local level = require("level")
local sprites = require("sprites")
local mobile = require("mobile")

-- Game state variables
local gameCamera
local mario
local levelManager
local score
local gameTime
local lives
local currentLevelName
local gameInitialized = false
local isMobile = false

function love.load()
    -- Detect mobile platform
    isMobile = mobile.init()
    
    -- Adjust window for mobile if needed
    if isMobile then
        love.window.setTitle(config.WINDOW_TITLE)
        -- Mobile devices will use their native resolution
    else
        love.window.setTitle(config.WINDOW_TITLE)
        love.window.setMode(config.WINDOW_WIDTH, config.WINDOW_HEIGHT)
    end
    
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
    if isMobile then
        love.graphics.print("Touch anywhere to start game", screenWidth/2 - 100, 300)
    else
        love.graphics.print("Press SPACE to start game", screenWidth/2 - 100, 300)
    end
    love.graphics.print("Press ESCAPE to exit", screenWidth/2 - 80, 330)
    
    -- Show platform info
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print("Princess sprites loaded from princess/ folder", screenWidth/2 - 140, 380)
    if isMobile then
        love.graphics.print("Mobile controls enabled", screenWidth/2 - 80, 400)
    else
        love.graphics.print("Camera follows vertically between Y: 210-250", screenWidth/2 - 120, 400)
    end
    
    love.graphics.present()
end

function initializeGame()
    -- Initialize camera with limited vertical range
    gameCamera = camera.new()
    gameCamera.zoom = isMobile and 1.5 or config.ZOOM_FACTOR -- Smaller zoom for mobile
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
    -- Update mobile controls
    if isMobile then
        mobile.update(dt)
    end
    
    if gameInitialized then
        if not mario.alive then
            return
        end
        
        gameTime = gameTime + dt
        
        -- Update Princess
        player.updateMobile(mario, dt, levelManager.platforms, isMobile)
        
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
    
    -- Draw background (sky)
    love.graphics.setColor(config.COLORS.SKY)
    love.graphics.rectangle("fill", -200, -200, config.LEVEL_WIDTH + 400, love.graphics.getHeight() + 400)
    
    -- Draw ground
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
    
    -- Draw UI (fixed position)
    love.graphics.setColor(config.COLORS.WHITE)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("Time: " .. math.floor(gameTime), 10, 30)
    love.graphics.print("Level: " .. level.getCurrentLevelName(levelManager), 10, 50)
    love.graphics.print("Lives: " .. lives, 10, 70)
    if not isMobile then
        love.graphics.print("Zoom: " .. string.format("%.1f", gameCamera.zoom) .. "x", 10, 90)
        love.graphics.print("Camera Y: " .. string.format("%.0f", gameCamera.y) .. " (range: " .. gameCamera.minY .. "-" .. gameCamera.maxY .. ")", 10, 110)
    end
    
    -- Draw FPS in upper right corner
    local fps = love.timer.getFPS()
    local fpsText = "FPS: " .. fps
    local fpsWidth = love.graphics.getFont():getWidth(fpsText)
    love.graphics.print(fpsText, love.graphics.getWidth() - fpsWidth - 10, 10)
    
    -- Draw mobile controls
    if isMobile then
        mobile.drawControls()
    end
    
    if not mario.alive then
        love.graphics.setColor(config.COLORS.MARIO_RED)
        love.graphics.print("GAME OVER! Touch to restart", love.graphics.getWidth()/2 - 100, love.graphics.getHeight()/2)
        love.graphics.print("Lives remaining: " .. (lives - 1), love.graphics.getWidth()/2 - 50, love.graphics.getHeight()/2 + 20)
    end
    
    -- Draw level complete screen
    level.drawLevelComplete(levelManager)
end

-- Touch events for mobile
function love.touchpressed(id, x, y, dx, dy, pressure)
    if not gameInitialized then
        initializeGame()
        return
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
    
    -- Desktop-only controls
    if not isMobile then
        -- Zoom controls
        if key == "=" or key == "+" then
            gameCamera.zoom = math.min(gameCamera.zoom + 0.25, 4.0)
        elseif key == "-" or key == "_" then
            gameCamera.zoom = math.max(gameCamera.zoom - 0.25, 0.5)
        end
        
        -- Camera range adjustment controls
        if key == "pageup" then
            camera.adjustRange(gameCamera, -10, -10)
        elseif key == "pagedown" then
            camera.adjustRange(gameCamera, 10, 10)
        end
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
end