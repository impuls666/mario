-- Collision detection utilities
local collision = {}

-- Basic AABB collision detection
function collision.checkAABB(a, b)
    return a.x < b.x + b.width and
           b.x < a.x + a.width and
           a.y < b.y + b.height and
           b.y < a.y + a.height
end

-- Check if object A was above object B before the collision (for platform collision)
function collision.wasAbove(a, b, dt)
    local prevY = a.y - a.velY * dt
    return prevY + a.height <= b.y + 3 -- Small tolerance for pixel-perfect collision
end

-- Check if object A is moving downward
function collision.isMovingDown(a)
    return a.velY > 0
end

-- Check if object A is moving upward
function collision.isMovingUp(a)
    return a.velY < 0
end

-- Check if object A is moving right
function collision.isMovingRight(a)
    return a.velX > 0
end

-- Check if object A is moving left
function collision.isMovingLeft(a)
    return a.velX < 0
end

-- Resolve platform collision (only from above)
function collision.resolvePlatformCollision(a, platform, dt)
    if collision.checkAABB(a, platform) then
        if collision.isMovingDown(a) and collision.wasAbove(a, platform, dt) then
            a.y = platform.y - a.height
            a.velY = 0
            a.onGround = true
            return true
        end
    end
    return false
end

-- Resolve wall collision (from sides)
function collision.resolveWallCollision(a, wall)
    if collision.checkAABB(a, wall) then
        local overlapX = math.min(a.x + a.width - wall.x, wall.x + wall.width - a.x)
        local overlapY = math.min(a.y + a.height - wall.y, wall.y + wall.height - a.y)
        
        -- Resolve the smaller overlap (the direction of collision)
        if overlapX < overlapY then
            -- Horizontal collision
            if a.x < wall.x then
                -- Hit from left
                a.x = wall.x - a.width
            else
                -- Hit from right
                a.x = wall.x + wall.width
            end
            a.velX = 0
        else
            -- Vertical collision
            if a.y < wall.y then
                -- Hit from above
                a.y = wall.y - a.height
                a.velY = 0
                a.onGround = true
            else
                -- Hit from below
                a.y = wall.y + wall.height
                a.velY = 0
            end
        end
        return true
    end
    return false
end

return collision