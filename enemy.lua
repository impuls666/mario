-- Enemy (Goomba) logic
local config = require("config")
local collision = require("collision")

local enemy = {}

function enemy.new(x, y, speed)
    return {
        x = x,
        y = y,
        width = config.ENEMY.WIDTH,
        height = config.ENEMY.HEIGHT,
        velX = speed or -40,
        velY = 0, -- Add velY for consistency
        alive = true
    }
end

function enemy.update(goomba, dt, platforms)
    if not goomba.alive then
        return
    end
    
    -- Move the enemy
    goomba.x = goomba.x + goomba.velX * dt
    
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
        -- Enemy body
        love.graphics.setColor(config.COLORS.ENEMY_BROWN)
        love.graphics.rectangle("fill", goomba.x, goomba.y, goomba.width, goomba.height)
        
        -- Simple face
        love.graphics.setColor(config.COLORS.WHITE)
        love.graphics.circle("fill", goomba.x + 4, goomba.y + 4, 2)
        love.graphics.circle("fill", goomba.x + 12, goomba.y + 4, 2)
    end
end

return enemy 