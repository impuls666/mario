-- Princess player logic with sprite animations and proper scaling
local config = require("config")
local collision = require("collision")
local sprites = require("sprites")

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
        alive = true,
        -- Animation state
        isMoving = false,
        -- NOTE: Swapped the animations since your sprites are flipped
        leftAnimation = sprites.createAnimation("princess", "moveRight", 4, 0.15),  -- Using moveRight for left
        rightAnimation = sprites.createAnimation("princess", "moveLeft", 4, 0.15),  -- Using moveLeft for right
        currentAnimation = nil,
        -- Sprite scaling (princess is 99x239, we want her about 24x32 like other characters)
        spriteScaleX = 24 / 99,   -- Scale down width from 99 to 24
        spriteScaleY = 32 / 239,  -- Scale down height from 239 to 32
        spriteOffsetX = 0,        -- X offset for positioning
        spriteOffsetY = 0         -- Y offset for positioning
    }
end

function player.update(mario, dt, platforms)
    if not mario.alive then
        return
    end
    
    -- Input handling
    local wasMoving = mario.isMoving
    mario.velX = 0
    mario.isMoving = false
    
    if love.keyboard.isDown("left", "a") then
        mario.velX = -mario.speed
        mario.facing = -1
        mario.isMoving = true
        mario.currentAnimation = mario.leftAnimation
    elseif love.keyboard.isDown("right", "d") then
        mario.velX = mario.speed
        mario.facing = 1
        mario.isMoving = true
        mario.currentAnimation = mario.rightAnimation
    end
    
    -- Handle animation state changes
    if mario.isMoving and not wasMoving then
        -- Started moving
        sprites.startAnimation(mario.currentAnimation)
    elseif not mario.isMoving and wasMoving then
        -- Stopped moving
        if mario.currentAnimation then
            sprites.stopAnimation(mario.currentAnimation)
        end
    end
    
    -- Update current animation
    if mario.currentAnimation then
        sprites.updateAnimation(mario.currentAnimation, dt)
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
        local sprite = nil
        local drewSprite = false
        
        -- Try to draw the appropriate sprite
        if mario.isMoving and mario.currentAnimation then
            sprite = sprites.getCurrentFrame(mario.currentAnimation)
        else
            -- When not moving, show the first frame of the appropriate direction
            -- NOTE: Using swapped directions since sprites are flipped
            local idleDirection = mario.facing == 1 and "moveLeft" or "moveRight"
            sprite = sprites.getFrame("princess", idleDirection, 1)
        end
        
        -- Draw the sprite with proper scaling
        if sprite then
            drewSprite = sprites.drawSprite(
                sprite, 
                mario.x, 
                mario.y, 
                mario.spriteScaleX, 
                mario.spriteScaleY, 
                mario.spriteOffsetX, 
                mario.spriteOffsetY
            )
        end
        
        -- Fallback drawing if no sprite was drawn
        if not drewSprite then
            -- Princess-themed fallback colors
            love.graphics.setColor(1, 0.75, 0.8) -- Pink dress
            love.graphics.rectangle("fill", mario.x, mario.y, mario.width, mario.height)
            
            -- Princess face
            love.graphics.setColor(1, 0.9, 0.8) -- Skin tone
            love.graphics.rectangle("fill", mario.x + 4, mario.y + 4, mario.width - 8, 12)
            
            -- Crown
            love.graphics.setColor(1, 1, 0) -- Gold crown
            love.graphics.rectangle("fill", mario.x + 2, mario.y, mario.width - 4, 8)
            
            -- Eyes
            love.graphics.setColor(0, 0, 0)
            if mario.facing == 1 then
                love.graphics.circle("fill", mario.x + 14, mario.y + 8, 1)
                love.graphics.circle("fill", mario.x + 18, mario.y + 8, 1)
            else
                love.graphics.circle("fill", mario.x + 6, mario.y + 8, 1)
                love.graphics.circle("fill", mario.x + 10, mario.y + 8, 1)
            end
        end
        
        -- Debug: Draw collision box (optional - remove this line to hide)
        -- love.graphics.setColor(1, 0, 0, 0.3)
        -- love.graphics.rectangle("line", mario.x, mario.y, mario.width, mario.height)
        
    else
        -- Game over visual effect
        love.graphics.setColor(1, 0.75, 0.8) -- Pink
        love.graphics.rectangle("fill", mario.x - 10, mario.y - 10, mario.width + 20, mario.height + 20)
    end
end

return player 