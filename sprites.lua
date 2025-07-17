-- Sprite management system for princess character and skeleton enemies
local sprites = {}

local loadedSprites = {}

function sprites.load()
    -- Initialize sprite storage
    loadedSprites.princess = {
        moveLeft = {},   -- Will store frames 1-5.png to 1-8.png
        moveRight = {}   -- Will store frames 1-13.png to 1-16.png
    }
    
    loadedSprites.skeleton = {
        moveLeft = {}    -- Will store frames 1.png to 4.png
    }
    
    -- Load princess moving left sprites (1-5.png to 1-8.png)
    for i = 5, 8 do
        local path = "princess/1-" .. i .. ".png"
        sprites.tryLoadSprite("princess", "moveLeft", i - 4, path) -- Store as index 1-4
    end
    
    -- Load princess moving right sprites (1-13.png to 1-16.png)
    for i = 13, 16 do
        local path = "princess/1-" .. i .. ".png"
        sprites.tryLoadSprite("princess", "moveRight", i - 12, path) -- Store as index 1-4
    end
    
    -- Load skeleton enemy sprites (1.png to 4.png)
    for i = 1, 4 do
        local path = "skeleton/" .. i .. ".png"
        sprites.tryLoadSprite("skeleton", "moveLeft", i, path) -- Store as index 1-4
    end
    
    print("Finished loading princess and skeleton sprites")
end

function sprites.tryLoadSprite(category, direction, frameIndex, path)
    local success, image = pcall(love.graphics.newImage, path)
    if success then
        loadedSprites[category][direction][frameIndex] = image
        print("Loaded sprite: " .. path .. " - Size: " .. image:getWidth() .. "x" .. image:getHeight())
    else
        print("Failed to load sprite: " .. path .. " (using fallback)")
        loadedSprites[category][direction][frameIndex] = nil
    end
end

function sprites.getFrame(category, direction, frameIndex)
    if loadedSprites[category] and loadedSprites[category][direction] and loadedSprites[category][direction][frameIndex] then
        return loadedSprites[category][direction][frameIndex]
    end
    return nil
end

-- Animation system
function sprites.createAnimation(category, direction, numFrames, frameTime)
    return {
        category = category,
        direction = direction,
        numFrames = numFrames,
        frameTime = frameTime,
        currentFrame = 1,
        timer = 0,
        isPlaying = false
    }
end

function sprites.updateAnimation(animation, dt)
    if animation.isPlaying then
        animation.timer = animation.timer + dt
        if animation.timer >= animation.frameTime then
            animation.timer = animation.timer - animation.frameTime
            animation.currentFrame = animation.currentFrame + 1
            if animation.currentFrame > animation.numFrames then
                animation.currentFrame = 1
            end
        end
    end
end

function sprites.startAnimation(animation)
    animation.isPlaying = true
end

function sprites.stopAnimation(animation)
    animation.isPlaying = false
    animation.currentFrame = 1
    animation.timer = 0
end

function sprites.getCurrentFrame(animation)
    return sprites.getFrame(animation.category, animation.direction, animation.currentFrame)
end

-- Drawing functions with scaling support
function sprites.drawSprite(sprite, x, y, scaleX, scaleY, offsetX, offsetY, flipX)
    if sprite then
        local sx = scaleX or 1
        local sy = scaleY or 1
        local ox = offsetX or 0
        local oy = offsetY or 0
        
        -- Handle horizontal flipping
        if flipX then
            sx = -sx
            ox = ox + sprite:getWidth() * math.abs(scaleX or 1)
        end
        
        love.graphics.draw(sprite, x + ox, y + oy, 0, sx, sy)
        return true
    end
    return false
end

function sprites.drawSpriteWithFallback(category, direction, frameIndex, x, y, width, height, fallbackColor, scaleX, scaleY, offsetX, offsetY, flipX)
    local sprite = sprites.getFrame(category, direction, frameIndex)
    
    if sprites.drawSprite(sprite, x, y, scaleX, scaleY, offsetX, offsetY, flipX) then
        return true
    else
        -- Fallback to colored rectangle
        love.graphics.setColor(fallbackColor)
        love.graphics.rectangle("fill", x, y, width, height)
        return false
    end
end

return sprites 