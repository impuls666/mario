-- Mario player logic
local config = require("config")
local collision = require("collision")

local player = {}

function player.new(x, y)
    return {
        x = x,
        y = y,
        width = config.PLAYER.WIDTH,
        height = config.PLAYER.HEIGHT,
        velX = 0,
        velY = 0,
        speed = config.PLAYER.SPEED,
        jumpPower = config.PLAYER.JUMP_POWER,
        onGround = false,
        facing = 1, -- 1 for right, -1 for left
        alive = true
    }
end

function player.update(mario, dt, platforms)
    if not mario.alive then
        return
    end
    
    -- Input handling
    mario.velX = 0
    
    if love.keyboard.isDown("left", "a") then
        mario.velX = -mario.speed
        mario.facing = -1
    end
    if love.keyboard.isDown("right", "d") then
        mario.velX = mario.speed
        mario.facing = 1
    end
    
    -- Jumping
    if love.keyboard.isDown("space", "up", "w") and mario.onGround then
        mario.velY = -mario.jumpPower
        mario.onGround = false
    end
    
    -- Apply gravity
    mario.velY = mario.velY + config.GRAVITY * dt
    
    -- Update position (separate X and Y for better collision handling)
    mario.x = mario.x + mario.velX * dt
    mario.y = mario.y + mario.velY * dt
    
    -- Reset onGround state (will be set to true if touching ground/platform)
    mario.onGround = false
    
    -- Ground collision
    if mario.y + mario.height >= config.GROUND_Y then
        mario.y = config.GROUND_Y - mario.height
        mario.velY = 0
        mario.onGround = true
    end
    
    -- Platform collision
    for _, platform in ipairs(platforms) do
        if collision.resolvePlatformCollision(mario, platform, dt) then
            -- Collision was resolved in the function
            break -- Only collide with one platform at a time
        end
    end
    
    -- Keep Mario in bounds
    if mario.x < 0 then
        mario.x = 0
        mario.velX = 0
    elseif mario.x + mario.width > config.LEVEL_WIDTH then
        mario.x = config.LEVEL_WIDTH - mario.width
        mario.velX = 0
    end
    
    -- Mario falls off the world
    if mario.y > love.graphics.getHeight() + 100 then
        mario.alive = false
    end
end

function player.draw(mario)
    if mario.alive then
        -- Mario's red shirt
        love.graphics.setColor(config.COLORS.MARIO_RED)
        love.graphics.rectangle("fill", mario.x, mario.y, mario.width, mario.height)
        
        -- Mario's face
        love.graphics.setColor(config.COLORS.MARIO_SKIN)
        love.graphics.rectangle("fill", mario.x + 4, mario.y + 4, mario.width - 8, 12)
        
        -- Mario's hat
        love.graphics.setColor(config.COLORS.MARIO_RED)
        love.graphics.rectangle("fill", mario.x + 2, mario.y, mario.width - 4, 8)
        
        -- Mario's eyes
        love.graphics.setColor(config.COLORS.BLACK)
        if mario.facing == 1 then
            love.graphics.circle("fill", mario.x + 14, mario.y + 8, 1)
            love.graphics.circle("fill", mario.x + 18, mario.y + 8, 1)
        else
            love.graphics.circle("fill", mario.x + 6, mario.y + 8, 1)
            love.graphics.circle("fill", mario.x + 10, mario.y + 8, 1)
        end
    else
        -- Game over visual effect
        love.graphics.setColor(config.COLORS.MARIO_RED)
        love.graphics.rectangle("fill", mario.x - 10, mario.y - 10, mario.width + 20, mario.height + 20)
    end
end

return player 