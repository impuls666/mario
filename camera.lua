-- Camera system for following the player
local camera = {}

function camera.new()
    return {
        x = 0,
        y = 0
    }
end

function camera.update(cam, target, levelWidth, screenWidth)
    -- Follow the target (usually the player)
    cam.x = target.x - screenWidth / 2
    
    -- Keep camera within level bounds
    if cam.x < 0 then
        cam.x = 0
    elseif cam.x > levelWidth - screenWidth then
        cam.x = levelWidth - screenWidth
    end
end

function camera.apply(cam)
    love.graphics.push()
    love.graphics.translate(-cam.x, -cam.y)
end

function camera.unapply()
    love.graphics.pop()
end

return camera 