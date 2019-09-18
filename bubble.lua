
Bubble = {}
Bubble.__index = Bubble

local VERTICAL_SPEED = 40

function Bubble:create(map, x, y)
    local this = {
        map = map,

        x = x,
        y = y,

        shouldBurst = false,
    }

    setmetatable(this, self)
    return this
end

function Bubble:update(dt)
    self.y = self.y - VERTICAL_SPEED * dt

    if self.y <= self.map.mapHeight + self.map.waveHeight + self.map.tileHeight then
        self.shouldBurst = true
    end
end

function Bubble:render()
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("line", self.x, self.y, 2, 10)
end

function Bubble:destroy()
end