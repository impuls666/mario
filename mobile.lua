-- Mobile-specific functions for touch controls
local mobile = {}

-- Touch control state
local touchControls = {
    leftPressed = false,
    rightPressed = false,
    jumpPressed = false,
    pausePressed = false
}

-- Touch button areas (in screen coordinates)
local buttons = {
    left = {x = 50, y = 450, width = 80, height = 80},
    right = {x = 150, y = 450, width = 80, height = 80},
    jump = {x = 650, y = 430, width = 100, height = 100},
    pause = {x = 20, y = 20, width = 60, height = 40}
}

function mobile.init()
    -- Detect if running on mobile
    local os = love.system.getOS()
    return os == "Android" or os == "iOS"
end

function mobile.update(dt)
    -- Reset touch states
    touchControls.leftPressed = false
    touchControls.rightPressed = false
    touchControls.jumpPressed = false
    touchControls.pausePressed = false
    
    -- Check for active touches
    local touches = love.touch.getTouches()
    for _, id in ipairs(touches) do
        local x, y = love.touch.getPosition(id)
        
        -- Check each button
        if mobile.isPointInButton(x, y, buttons.left) then
            touchControls.leftPressed = true
        elseif mobile.isPointInButton(x, y, buttons.right) then
            touchControls.rightPressed = true
        elseif mobile.isPointInButton(x, y, buttons.jump) then
            touchControls.jumpPressed = true
        elseif mobile.isPointInButton(x, y, buttons.pause) then
            touchControls.pausePressed = true
        end
    end
end

function mobile.isPointInButton(x, y, button)
    return x >= button.x and x <= button.x + button.width and
           y >= button.y and y <= button.y + button.height
end

function mobile.drawControls()
    -- Draw semi-transparent touch controls
    love.graphics.setColor(1, 1, 1, 0.3)
    
    -- Left arrow
    love.graphics.rectangle("fill", buttons.left.x, buttons.left.y, buttons.left.width, buttons.left.height)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.print("←", buttons.left.x + 30, buttons.left.y + 30)
    
    -- Right arrow
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.rectangle("fill", buttons.right.x, buttons.right.y, buttons.right.width, buttons.right.height)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.print("→", buttons.right.x + 30, buttons.right.y + 30)
    
    -- Jump button
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.rectangle("fill", buttons.jump.x, buttons.jump.y, buttons.jump.width, buttons.jump.height)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.print("JUMP", buttons.jump.x + 25, buttons.jump.y + 40)
    
    -- Pause button
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.rectangle("fill", buttons.pause.x, buttons.pause.y, buttons.pause.width, buttons.pause.height)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.print("||", buttons.pause.x + 20, buttons.pause.y + 10)
end

function mobile.isLeftPressed()
    return touchControls.leftPressed or love.keyboard.isDown("left", "a")
end

function mobile.isRightPressed()
    return touchControls.rightPressed or love.keyboard.isDown("right", "d")
end

function mobile.isJumpPressed()
    return touchControls.jumpPressed or love.keyboard.isDown("space", "up", "w")
end

function mobile.isPausePressed()
    return touchControls.pausePressed
end

return mobile 