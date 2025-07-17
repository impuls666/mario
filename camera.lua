-- Camera system with limited vertical following
local camera = {}

function camera.new()
    return {
        x = 0,
        y = 230,  -- Start in middle of our range (210-250)
        zoom = 2.0,
        minY = 210,  -- Minimum Y position
        maxY = 250   -- Maximum Y position
    }
end

function camera.update(cam, target, levelWidth, screenWidth, screenHeight)
    -- Follow the target horizontally
    cam.x = target.x - (screenWidth / cam.zoom) / 2
    
    -- Follow the target vertically but within limited range
    local targetY = target.y - (screenHeight / cam.zoom) / 2
    
    -- Clamp the Y position to our defined range
    cam.y = targetY
    if cam.y < cam.minY then
        cam.y = cam.minY
    elseif cam.y > cam.maxY then
        cam.y = cam.maxY
    end
    
    -- Keep camera within level bounds horizontally
    if cam.x < 0 then
        cam.x = 0
    elseif cam.x > levelWidth - (screenWidth / cam.zoom) then
        cam.x = levelWidth - (screenWidth / cam.zoom)
    end
end

function camera.apply(cam)
    love.graphics.push()
    love.graphics.scale(cam.zoom, cam.zoom)
    love.graphics.translate(-cam.x, -cam.y)
end

function camera.unapply()
    love.graphics.pop()
end

-- Convert screen coordinates to world coordinates
function camera.screenToWorld(cam, screenX, screenY)
    local worldX = (screenX / cam.zoom) + cam.x
    local worldY = (screenY / cam.zoom) + cam.y
    return worldX, worldY
end

-- Convert world coordinates to screen coordinates
function camera.worldToScreen(cam, worldX, worldY)
    local screenX = (worldX - cam.x) * cam.zoom
    local screenY = (worldY - cam.y) * cam.zoom
    return screenX, screenY
end

-- Adjust camera Y range
function camera.adjustRange(cam, minDelta, maxDelta)
    cam.minY = cam.minY + minDelta
    cam.maxY = cam.maxY + maxDelta
    
    -- Ensure min is always less than max
    if cam.minY >= cam.maxY then
        cam.minY = cam.maxY - 5
    end
    
    -- Clamp current position to new range
    if cam.y < cam.minY then
        cam.y = cam.minY
    elseif cam.y > cam.maxY then
        cam.y = cam.maxY
    end
end

-- Set new camera Y range
function camera.setRange(cam, minY, maxY)
    cam.minY = minY
    cam.maxY = maxY
    
    -- Ensure min is always less than max
    if cam.minY >= cam.maxY then
        cam.minY = cam.maxY - 5
    end
    
    -- Clamp current position to new range
    if cam.y < cam.minY then
        cam.y = cam.minY
    elseif cam.y > cam.maxY then
        cam.y = cam.maxY
    end
end

return camera 