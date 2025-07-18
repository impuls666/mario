-- Simple bullet system
local config = require("config")
local collision = require("collision")

local bullet = {}

function bullet.new(x, y, direction)
    return {
        x = x,
        y = y,
        width = 4,
        height = 2,
        speed = 300,
        direction = direction, -- 1 for right, -1 for left
        alive = true
    }
end

function bullet.update(bulletObj, dt)
    if bulletObj.alive then
        bulletObj.x = bulletObj.x + bulletObj.speed * bulletObj.direction * dt
        
        -- Remove bullet if it goes off screen
        if bulletObj.x < -10 or bulletObj.x > config.LEVEL_WIDTH + 10 then
            bulletObj.alive = false
        end
    end
end

function bullet.draw(bulletObj)
    if bulletObj.alive then
        love.graphics.setColor(1, 1, 0) -- Yellow bullet
        love.graphics.rectangle("fill", bulletObj.x, bulletObj.y, bulletObj.width, bulletObj.height)
    end
end

function bullet.checkEnemyCollision(bulletObj, enemy)
    if bulletObj.alive and enemy.alive and collision.checkAABB(bulletObj, enemy) then
        bulletObj.alive = false
        enemy.health = enemy.health - 1
        if enemy.health <= 0 then
            enemy.alive = false
            return true -- Enemy defeated
        end
        return false -- Enemy hit but not defeated
    end
    return false
end

return bullet 