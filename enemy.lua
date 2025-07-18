-- Enemy with health system
local config = require("config")
local collision = require("collision")
local sprites = require("sprites")

local enemy = {}

function enemy.new(x, y, speed, health)
    return {
        x = x,
        y = y,
        width = config.ENEMY.WIDTH,
        height = config.ENEMY.HEIGHT,
        velX = speed or -40,
        velY = 0,
        alive = true,
        health = health or 3, -- Default 3 health
        maxHealth = health or 3,
        stunned = false,
        stunTimer = 0,
        -- Animation state
        walkAnimation = sprites.createAnimation("skeleton", "moveLeft", 4, 0.2),
        spriteScaleX = 24 / 60,
        spriteScaleY = 32 / 140,
        spriteOffsetX = 0,
        spriteOffsetY = 0,
        facing = -1
    }
end

function enemy.update(goomba, dt, platforms)
    if not goomba.alive then
        return
    end
    
    -- Handle stun
    if goomba.stunned then
        goomba.stunTimer = goomba.stunTimer - dt
        if goomba.stunTimer <= 0 then
            goomba.stunned = false
        end
        return -- Don't move while stunned
    end
    
    -- Normal movement and animation
    sprites.startAnimation(goomba.walkAnimation)
    sprites.updateAnimation(goomba.walkAnimation, dt)
    
    goomba.x = goomba.x + goomba.velX * dt
    
    if goomba.velX < 0 then
        goomba.facing = -1
    elseif goomba.velX > 0 then
        goomba.facing = 1
    end
    
    -- Ground and platform collision (same as before)
    if goomba.y + goomba.height >= config.GROUND_Y then
        goomba.y = config.GROUND_Y - goomba.height
    end
    
    for _, platform in ipairs(platforms) do
        if collision.checkAABB(goomba, platform) then
            if goomba.y < platform.y then
                goomba.y = platform.y - goomba.height
            end
        end
    end
    
    if goomba.x <= 0 or goomba.x + goomba.width >= config.LEVEL_WIDTH then
        goomba.velX = -goomba.velX
    end
end

function enemy.checkPlayerCollision(goomba, mario, dt)
    if not goomba.alive or not mario.alive then
        return false, false
    end
    
    if collision.checkAABB(mario, goomba) then
        local marioWasAbove = collision.wasAbove(mario, goomba, dt)
        
        if collision.isMovingDown(mario) and marioWasAbove then
            goomba.alive = false
            mario.velY = -300
            return true, true
        else
            mario.alive = false
            return true, false
        end
    end
    
    return false, false
end

function enemy.stun(goomba, duration)
    goomba.stunned = true
    goomba.stunTimer = duration or 2.0 -- 2 seconds default
end

function enemy.drawHealthBar(goomba)
    if goomba.alive and goomba.health < goomba.maxHealth then
        local barWidth = 20
        local barHeight = 4
        local barX = goomba.x + (goomba.width - barWidth) / 2
        local barY = goomba.y - 8
        
        -- Background (red)
        love.graphics.setColor(0.8, 0.2, 0.2)
        love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
        
        -- Health (green)
        local healthWidth = (goomba.health / goomba.maxHealth) * barWidth
        love.graphics.setColor(0.2, 0.8, 0.2)
        love.graphics.rectangle("fill", barX, barY, healthWidth, barHeight)
        
        -- Border
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line", barX, barY, barWidth, barHeight)
    end
end

function enemy.draw(goomba)
    if goomba.alive then
        local sprite = sprites.getCurrentFrame(goomba.walkAnimation)
        local flipSprite = goomba.facing == 1
        local drewSprite = false
        
        -- Tint if stunned
        if goomba.stunned then
            love.graphics.setColor(0.5, 0.5, 1) -- Blue tint for stun
        else
            love.graphics.setColor(1, 1, 1) -- Normal color
        end
        
        if sprite then
            drewSprite = sprites.drawSprite(sprite, goomba.x, goomba.y, goomba.spriteScaleX, goomba.spriteScaleY, goomba.spriteOffsetX, goomba.spriteOffsetY, flipSprite)
        end
        
        if not drewSprite then
            local color = goomba.stunned and config.COLORS.SKELETON_BONE or config.COLORS.ENEMY_BROWN
            love.graphics.setColor(color)
            love.graphics.rectangle("fill", goomba.x, goomba.y, goomba.width, goomba.height)
        end
        
        -- Draw health bar
        enemy.drawHealthBar(goomba)
    end
end

return enemy 