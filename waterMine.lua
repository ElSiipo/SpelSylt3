
WaterMine = {}
WaterMine.__index = WaterMine

local VERTICAL_SPEED = 40
local MAX_HEIGHT = 0
local MIN_HEIGHT = 0

function WaterMine:create(map, x, y)
    local this = {
        mine_sprite = love.graphics.newImage('graphics/mineScaled.png'),
        map = map,

        x = x,
        y = y,

        shouldMoveUp = false,
        shouldExplode = false,
    }

    MAX_HEIGHT = this.y
    MIN_HEIGHT = this.y + 150

    setmetatable(this, self)
    return this
end

function WaterMine:update(dt)
    if self.shouldMoveUp then
        self.y = self.y - VERTICAL_SPEED * dt

        if self.y <= MAX_HEIGHT then
            self.shouldMoveUp = false
        end
    else
        self.y = self.y + VERTICAL_SPEED * dt

        if self.y >= MIN_HEIGHT then
            self.shouldMoveUp = true
        end
    end

    if isBetweenValues(self.y, math.floor(self.map.player.y), math.floor(self.map.player.y) + 16) and
        isBetweenValues(self.x, math.floor(self.map.player.x), math.floor(self.map.player.x) + 16) then
            self.shouldExplode = true
    end
end

function isBetweenValues(currentValue, firstValue, secondValue)
    return currentValue > firstValue and currentValue < secondValue
end

function WaterMine:render()
    love.graphics.draw( self.mine_sprite, self.x , self.y)
    love.graphics.setColor(1, 1, 1)
end

function WaterMine:destroy()
end