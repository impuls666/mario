-- Main game file with mobile support
local config = require("config")
local camera = require("camera")
local player = require("player")
local enemy = require("enemy")
local coin = require("coin")
local level = require("level")
local sprites = require("sprites")
local mobile = require("mobile")
local bullet = require("bullet")

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
local bullets = {}

-- Simpler approach - add a gameState variable
local gameState = "menu" -- "menu", "playing", "lostlife", "truegameover"

-- Audio variables
local backgroundMusic

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
    
    -- Load and play background music
    print("Loading background music...")
    backgroundMusic = love.audio.newSource("music/i am running out of time.mp3", "stream")
    backgroundMusic:setLooping(true)  -- Loop the music continuously
    backgroundMusic:setVolume(config.AUDIO.MUSIC_VOLUME)
    if config.AUDIO.MUSIC_ENABLED then
        backgroundMusic:play()
        print("Background music started")
    else
        print("Background music loaded but disabled")
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
    love.graphics.print("Press M to toggle music", screenWidth/2 - 85, 350)
    
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

-- Update the love.keypressed function to properly handle game over
function love.keypressed(key)
    if gameState == "menu" then
        if key == "space" then
            initializeGame()
            gameState = "playing"
        elseif key == "escape" then
            love.event.quit()
        end
        return
    end
    
    if gameState == "lostlife" then
        if key == "escape" then
            love.event.quit()
        else
            -- Any other key
            lives = lives - 1
            if lives > 0 then
                -- Still have lives - restart current level
                mario.alive = true
                currentLevelName = level.loadLevel(levelManager, levelManager.currentLevel)
                mario.x = 100
                mario.y = config.GROUND_Y - mario.height
                mario.velX = 0
                mario.velY = 0
                mario.onGround = false
                gameState = "playing"
            else
                -- No lives left - true game over
                gameState = "truegameover"
            end
        end
        return
    end
    
    if gameState == "truegameover" then
        if key == "escape" then
            love.event.quit()
        else
            -- Any key to return to menu
            gameState = "menu"
            gameInitialized = false
            -- Reset for new game
            score = 0
            gameTime = 0
            lives = 3
            bullets = {}
        end
        return
    end
    
    if gameState == "playing" then
        -- All the game controls
        if key == "x" and player.shoot(mario) then
            local bulletX = mario.facing == 1 and mario.x + mario.width or mario.x
            local bulletY = mario.y + mario.height / 2
            table.insert(bullets, bullet.new(bulletX, bulletY, mario.facing))
        end
        
        if key == "z" and player.stun(mario) then
            for _, goomba in ipairs(levelManager.enemies) do
                local distance = math.abs(mario.x - goomba.x)
                if distance < 50 then
                    enemy.stun(goomba, 2.0)
                end
            end
        end
        
        if key == "r" or key == "R" then
            initializeGame()
        end
        
        if not isMobile then
            if key == "=" or key == "+" then
                gameCamera.zoom = math.min(gameCamera.zoom + 0.25, 4.0)
            elseif key == "-" or key == "_" then
                gameCamera.zoom = math.max(gameCamera.zoom - 0.25, 0.5)
            elseif key == "pageup" then
                camera.adjustRange(gameCamera, -10, -10)
            elseif key == "pagedown" then
                camera.adjustRange(gameCamera, 10, 10)
            end
        end
    end
    
    if key == "escape" then
        love.event.quit()
    end
end

-- Update the game update to handle state changes
function love.update(dt)
    if isMobile then
        mobile.update(dt)
    end
    
    if gameState ~= "playing" or not gameInitialized then
        return
    end
    
    -- Check for death and change state
    if not mario.alive then
        gameState = "lostlife"  -- Changed from "gameover"
        return
    end
    
    -- Normal game update
    gameTime = gameTime + dt
    player.updateMobile(mario, dt, levelManager.platforms, isMobile)
    
    -- Update bullets
    for i = #bullets, 1, -1 do
        bullet.update(bullets[i], dt)
        if not bullets[i].alive then
            table.remove(bullets, i)
        end
    end
    
    -- Check bullet-enemy collisions
    for _, bulletObj in ipairs(bullets) do
        for _, goomba in ipairs(levelManager.enemies) do
            if bullet.checkEnemyCollision(bulletObj, goomba) then
                score = score + 50
            end
        end
    end
    
    -- Update enemies
    for _, goomba in ipairs(levelManager.enemies) do
        enemy.update(goomba, dt, levelManager.platforms)
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
    
    -- Update level (this handles level completion!)
    level.update(levelManager, mario, dt)
    
    -- Update camera
    camera.update(gameCamera, mario, config.LEVEL_WIDTH, config.WINDOW_WIDTH, config.WINDOW_HEIGHT)
end

-- Simpler draw function
function love.draw()
    if gameState == "menu" then
        showMainMenu()
    elseif gameState == "playing" or gameState == "lostlife" or gameState == "truegameover" then
        -- Draw game
        camera.apply(gameCamera)
        
        love.graphics.setColor(config.COLORS.SKY)
        love.graphics.rectangle("fill", -200, -200, config.LEVEL_WIDTH + 400, love.graphics.getHeight() + 400)
        
        love.graphics.setColor(config.COLORS.GROUND)
        love.graphics.rectangle("fill", 0, config.GROUND_Y, config.LEVEL_WIDTH, love.graphics.getHeight() - config.GROUND_Y + 200)
        
        love.graphics.setColor(config.COLORS.PLATFORM)
        for _, platform in ipairs(levelManager.platforms) do
            love.graphics.rectangle("fill", platform.x, platform.y, platform.width, platform.height)
        end
        
        for _, coinObj in ipairs(levelManager.coins) do
            coin.draw(coinObj)
        end
        
        for _, goomba in ipairs(levelManager.enemies) do
            enemy.draw(goomba)
        end
        
        level.drawGoal(levelManager)
        
        for _, bulletObj in ipairs(bullets) do
            bullet.draw(bulletObj)
        end
        
        player.draw(mario)
        camera.unapply()
        
        -- UI
        love.graphics.setColor(config.COLORS.WHITE)
        love.graphics.print("Score: " .. score, 10, 10)
        love.graphics.print("Time: " .. math.floor(gameTime), 10, 30)
        love.graphics.print("Level: " .. level.getCurrentLevelName(levelManager), 10, 50)
        love.graphics.print("Lives: " .. lives, 10, 70)
        
        local fps = love.timer.getFPS()
        local fpsText = "FPS: " .. fps
        local fpsWidth = love.graphics.getFont():getWidth(fpsText)
        love.graphics.print(fpsText, love.graphics.getWidth() - fpsWidth - 10, 10)
        
        if isMobile then
            mobile.drawControls()
        end
        
        -- Lost life screen
        if gameState == "lostlife" then
            love.graphics.setColor(config.COLORS.MARIO_RED)
            if isMobile then
                love.graphics.print("OUCH! Touch to continue", love.graphics.getWidth()/2 - 80, love.graphics.getHeight()/2)
            else
                love.graphics.print("OUCH! Press any key to continue", love.graphics.getWidth()/2 - 100, love.graphics.getHeight()/2)
            end
            love.graphics.print("Lives remaining: " .. (lives - 1), love.graphics.getWidth()/2 - 50, love.graphics.getHeight()/2 + 20)
        end
        
        -- True game over screen
        if gameState == "truegameover" then
            love.graphics.setColor(1, 0, 0, 0.8)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("GAME OVER!", love.graphics.getWidth()/2 - 50, love.graphics.getHeight()/2 - 40)
            love.graphics.print("Final Score: " .. score, love.graphics.getWidth()/2 - 50, love.graphics.getHeight()/2 - 10)
            if isMobile then
                love.graphics.print("Touch to return to menu", love.graphics.getWidth()/2 - 80, love.graphics.getHeight()/2 + 20)
            else
                love.graphics.print("Press any key to return to menu", love.graphics.getWidth()/2 - 100, love.graphics.getHeight()/2 + 20)
            end
        end
        
        -- Level complete screen
        if levelManager and levelManager.showLevelComplete then
            level.drawLevelComplete(levelManager)
        end
        
        -- Instructions (only during playing)
        if gameState == "playing" and mario.alive then
            love.graphics.setColor(config.COLORS.WHITE)
            if isMobile then
                love.graphics.print("Touch controls: Move, Jump, Shoot (X), Stun (Z)", 10, love.graphics.getHeight() - 40)
            else
                love.graphics.print("Controls: A/D move, Space jump, X shoot, Z stun", 10, love.graphics.getHeight() - 80)
                love.graphics.print("R to restart, +/- zoom, Page Up/Down camera", 10, love.graphics.getHeight() - 60)
            end
            love.graphics.print("Reach the flag to complete the level!", 10, love.graphics.getHeight() - 20)
        end
    end
end