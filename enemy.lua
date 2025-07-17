-- Enemy (Skeleton) logic with sprite animations - Princess-sized
local config = require("config")
local collision = require("collision")
local sprites = require("sprites")

local enemy = {}

function enemy.new(x, y, speed)
    return {
        x = x,
        y = y,
        width = config.ENEMY.WIDTH,   -- Now 24 (same as princess)
        height = config.ENEMY.HEIGHT, -- Now 32 (same as princess)
        velX = speed or -40,
        velY = 0,
        alive = true,
        -- Animation state
        walkAnimation = sprites.createAnimation("skeleton", "moveLeft", 4, 0.2), -- 4 frames, 0.2s each
        -- Sprite scaling (skeleton is 60x140, we want it about 24x32 like princess)
        spriteScaleX = 24 / 60,   -- Scale down width from 60 to 24
        spriteScaleY = 32 / 140,  -- Scale down height from 140 to 32
        spriteOffsetX = 0,        -- X offset for positioning
        spriteOffsetY = 0,        -- Y offset for positioning
        facing = -1               -- -1 for left, 1 for right
    }
end

function enemy.update(goomba, dt, platforms)
    if not goomba.alive then
        return
    end
    
    -- Always animate the skeleton
    sprites.startAnimation(goomba.walkAnimation)
    sprites.updateAnimation(goomba.walkAnimation, dt)
    
    -- Move the enemy
    goomba.x = goomba.x + goomba.velX * dt
    
    -- Update facing direction based on movement
    if goomba.velX < 0 then
        goomba.facing = -1 -- Moving left
    elseif goomba.velX > 0 then
        goomba.facing = 1  -- Moving right
    end
    
    -- Ground collision
    if goomba.y + goomba.height >= config.GROUND_Y then
        goomba.y = config.GROUND_Y - goomba.height
    end
    
    -- Platform collision
    for _, platform in ipairs(platforms) do
        if collision.checkAABB(goomba, platform) then
            if goomba.y < platform.y then
                goomba.y = platform.y - goomba.height
            end
        end
    end
    
    -- Wall collision (turn around)
    if goomba.x <= 0 or goomba.x + goomba.width >= config.LEVEL_WIDTH then
        goomba.velX = -goomba.velX
    end
end

function enemy.checkPlayerCollision(goomba, mario, dt)
    if not goomba.alive or not mario.alive then
        return false, false
    end
    
    if collision.checkAABB(mario, goomba) then
        -- Check if Mario was above the enemy before collision (jumped on it)
        local marioWasAbove = collision.wasAbove(mario, goomba, dt)
        
        if collision.isMovingDown(mario) and marioWasAbove then
            -- Mario jumps on enemy
            goomba.alive = false
            mario.velY = -300 -- Small bounce
            return true, true -- collision happened, enemy defeated
        else
            -- Mario gets hurt
            mario.alive = false
            return true, false -- collision happened, mario died
        end
    end
    
    return false, false -- no collision
end

function enemy.draw(goomba)
    if goomba.alive then
        local sprite = sprites.getCurrentFrame(goomba.walkAnimation)
        local drewSprite = false
        
        -- Determine if we need to flip the sprite
        -- Since skeleton sprites are facing left, flip when facing right
        local flipSprite = goomba.facing == 1
        
        -- Try to draw the skeleton sprite with proper scaling and flipping
        if sprite then
            drewSprite = sprites.drawSprite(
                sprite, 
                goomba.x, 
                goomba.y, 
                goomba.spriteScaleX, 
                goomba.spriteScaleY, 
                goomba.spriteOffsetX, 
                goomba.spriteOffsetY,
                flipSprite
            )
        end
        
        -- Fallback drawing if no sprite was drawn (now princess-sized)
        if not drewSprite then
            -- Skeleton body (fallback) - now bigger
            love.graphics.setColor(config.COLORS.SKELETON_BONE)
            love.graphics.rectangle("fill", goomba.x, goomba.y, goomba.width, goomba.height)
            
            -- Skeleton head
            love.graphics.setColor(config.COLORS.WHITE)
            love.graphics.rectangle("fill", goomba.x + 4, goomba.y + 2, goomba.width - 8, 12)
            
            -- Eye sockets
            love.graphics.setColor(config.COLORS.BLACK)
            if goomba.facing == 1 then
                love.graphics.circle("fill", goomba.x + 14, goomba.y + 8, 2)
                love.graphics.circle("fill", goomba.x + 18, goomba.y + 8, 2)
            else
                love.graphics.circle("fill", goomba.x + 6, goomba.y + 8, 2)
                love.graphics.circle("fill", goomba.x + 10, goomba.y + 8, 2)
            end
            
            -- Ribcage lines
            love.graphics.setColor(config.COLORS.BLACK)
            for i = 1, 3 do
                local y = goomba.y + 14 + (i * 4)
                love.graphics.line(goomba.x + 6, y, goomba.x + goomba.width - 6, y)
            end
        end
        
        -- Debug: Draw collision box (optional - remove this line to hide)
        -- love.graphics.setColor(1, 0, 0, 0.3)
        -- love.graphics.rectangle("line", goomba.x, goomba.y, goomba.width, goomba.height)
    end
end

return enemy 