-- Princess player logic with mobile support
local config = require("config")
local collision = require("collision")
local sprites = require("sprites")
local mobile = require("mobile")

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
        leftAnimation = sprites.createAnimation("princess", "moveRight", 4, 0.15),
        rightAnimation = sprites.createAnimation("princess", "moveLeft", 4, 0.15),
        currentAnimation = nil,
        -- Sprite scaling
        spriteScaleX = 24 / 99,
        spriteScaleY = 32 / 239,
        spriteOffsetX = 0,
        spriteOffsetY = 0
    }
end

function player.updateMobile(mario, dt, platforms, isMobile)
    if not mario.alive then
        return
    end
    
    -- Input handling (keyboard or mobile)
    local wasMoving = mario.isMoving
    mario.velX = 0
    mario.isMoving = false
    
    local leftPressed = isMobile and mobile.isLeftPressed() or love.keyboard.isDown("left", "a")
    local rightPressed = isMobile and mobile.isRightPressed() or love.keyboard.isDown("right", "d")
    local jumpPressed = isMobile and mobile.isJumpPressed() or love.keyboard.isDown("space", "up", "w")
    
    if leftPressed then
        mario.velX = -mario.speed
        mario.facing = -1
        mario.isMoving = true
        mario.currentAnimation = mario.leftAnimation
    elseif rightPressed then
        mario.velX = mario.speed
        mario.facing = 1
        mario.isMoving = true
        mario.currentAnimation = mario.rightAnimation
    end
    
    -- Handle animation state changes
    if mario.isMoving and not wasMoving then
        sprites.startAnimation(mario.currentAnimation)
    elseif not mario.isMoving and wasMoving then
        if mario.currentAnimation then
            sprites.stopAnimation(mario.currentAnimation)
        end
    end
    
    -- Update current animation
    if mario.currentAnimation then
        sprites.updateAnimation(mario.currentAnimation, dt)
    end
    
    -- Jumping
    if jumpPressed and mario.onGround then
        mario.velY = -mario.jumpPower
        mario.onGround = false
    end
    
    -- Rest of update logic remains the same...
    mario.velY = mario.velY + config.GRAVITY * dt
    mario.x = mario.x + mario.velX * dt
    mario.y = mario.y + mario.velY * dt
    
    mario.onGround = false
    
    if mario.y + mario.height >= config.GROUND_Y then
        mario.y = config.GROUND_Y - mario.height
        mario.velY = 0
        mario.onGround = true
    end
    
    for _, platform in ipairs(platforms) do
        if collision.resolvePlatformCollision(mario, platform, dt) then
            break
        end
    end
    
    if mario.x < 0 then
        mario.x = 0
        mario.velX = 0
    elseif mario.x + mario.width > config.LEVEL_WIDTH then
        mario.x = config.LEVEL_WIDTH - mario.width
        mario.velX = 0
    end
    
    if mario.y > love.graphics.getHeight() + 100 then
        mario.alive = false
    end
end

-- Keep original update function for backwards compatibility
function player.update(mario, dt, platforms)
    player.updateMobile(mario, dt, platforms, false)
end

function player.draw(mario)
    if mario.alive then
        local sprite = nil
        local drewSprite = false
        
        if mario.isMoving and mario.currentAnimation then
            sprite = sprites.getCurrentFrame(mario.currentAnimation)
        else
            local idleDirection = mario.facing == 1 and "moveLeft" or "moveRight"
            sprite = sprites.getFrame("princess", idleDirection, 1)
        end
        
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
        
        if not drewSprite then
            love.graphics.setColor(1, 0.75, 0.8)
            love.graphics.rectangle("fill", mario.x, mario.y, mario.width, mario.height)
            
            love.graphics.setColor(1, 0.9, 0.8)
            love.graphics.rectangle("fill", mario.x + 4, mario.y + 4, mario.width - 8, 12)
            
            love.graphics.setColor(1, 1, 0)
            love.graphics.rectangle("fill", mario.x + 2, mario.y, mario.width - 4, 8)
            
            love.graphics.setColor(0, 0, 0)
            if mario.facing == 1 then
                love.graphics.circle("fill", mario.x + 14, mario.y + 8, 1)
                love.graphics.circle("fill", mario.x + 18, mario.y + 8, 1)
            else
                love.graphics.circle("fill", mario.x + 6, mario.y + 8, 1)
                love.graphics.circle("fill", mario.x + 10, mario.y + 8, 1)
            end
        end
    else
        love.graphics.setColor(1, 0.75, 0.8)
        love.graphics.rectangle("fill", mario.x - 10, mario.y - 10, mario.width + 20, mario.height + 20)
    end
end

return player 