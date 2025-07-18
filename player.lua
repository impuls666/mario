-- Princess with shooting and stun abilities
local config = require("config")
local collision = require("collision")
local sprites = require("sprites")
local mobile = require("mobile")

local player = {}

function player.new(x, y)
    return {
        x = x, y = y, width = config.PLAYER.WIDTH, height = config.PLAYER.HEIGHT,
        velX = 0, velY = 0, speed = config.PLAYER.SPEED, jumpPower = config.PLAYER.JUMP_POWER,
        onGround = false, facing = 1, alive = true,
        -- Animation
        isMoving = false,
        leftAnimation = sprites.createAnimation("princess", "moveRight", 4, 0.15),
        rightAnimation = sprites.createAnimation("princess", "moveLeft", 4, 0.15),
        currentAnimation = nil,
        stopDelay = 0, -- Small delay for more natural stopping
        -- Sprite scaling
        spriteScaleX = 24 / 99, spriteScaleY = 32 / 239, spriteOffsetX = 0, spriteOffsetY = 0,
        -- Combat abilities
        shootCooldown = 0,
        stunCooldown = 0
    }
end

function player.updateMobile(mario, dt, platforms, isMobile)
    if not mario.alive then return end
    
    -- Update cooldowns
    mario.shootCooldown = math.max(0, mario.shootCooldown - dt)
    mario.stunCooldown = math.max(0, mario.stunCooldown - dt)
    
    -- Update stop delay for smoother animation
    mario.stopDelay = math.max(0, mario.stopDelay - dt)
    
    -- Movement input
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
    
    -- Animation handling with anticipatory stopping
    if mario.isMoving and not wasMoving then
        -- Started moving
        sprites.startAnimation(mario.currentAnimation)
        mario.stopDelay = 0
    elseif not mario.isMoving and wasMoving then
        -- Stopped moving - add small delay for more natural transition
        mario.stopDelay = 0.08 -- 80ms delay before stopping animation
    end
    
    -- Handle delayed animation stopping
    if not mario.isMoving and mario.stopDelay <= 0 and mario.currentAnimation and mario.currentAnimation.isPlaying then
        sprites.stopAnimationSmooth(mario.currentAnimation)
    end
    
    if mario.currentAnimation then
        sprites.updateAnimation(mario.currentAnimation, dt)
    end
    
    -- Jumping
    if jumpPressed and mario.onGround then
        mario.velY = -mario.jumpPower
        mario.onGround = false
    end
    
    -- Physics (same as before)
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

function player.canShoot(mario)
    return mario.shootCooldown <= 0
end

function player.shoot(mario)
    if player.canShoot(mario) then
        mario.shootCooldown = 0.3 -- 0.3 second cooldown
        return true
    end
    return false
end

function player.canStun(mario)
    return mario.stunCooldown <= 0
end

function player.stun(mario)
    if player.canStun(mario) then
        mario.stunCooldown = 3.0 -- 3 second cooldown
        return true
    end
    return false
end

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
            drewSprite = sprites.drawSprite(sprite, mario.x, mario.y, mario.spriteScaleX, mario.spriteScaleY, mario.spriteOffsetX, mario.spriteOffsetY)
        end
        
        if not drewSprite then
            -- Fallback drawing (same as before)
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