-- Coin collectible logic
local config = require("config")
local collision = require("collision")

local coin = {}

function coin.new(x, y)
    return {
        x = x,
        y = y,
        width = config.COIN.WIDTH,
        height = config.COIN.HEIGHT,
        collected = false
    }
end

function coin.checkCollection(coinObj, mario)
    if not coinObj.collected and collision.checkAABB(mario, coinObj) then
        coinObj.collected = true
        return true
    end
    return false
end

function coin.draw(coinObj)
    if not coinObj.collected then
        love.graphics.setColor(config.COLORS.COIN_YELLOW)
        love.graphics.circle("fill", coinObj.x + coinObj.width/2, coinObj.y + coinObj.height/2, coinObj.width/2)
    end
end

return coin