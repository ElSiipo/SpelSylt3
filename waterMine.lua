
WaterMine = {}
WaterMine.__index = WaterMine

local VERTICAL_SPEED = 40

function WaterMine:create(map, x, y)
    local this = {
        mine_sprite = love.graphics.newImage('graphics/mineScaled.png'),
        map = map,

        x = x,
        y = y,

        shouldExplode = false,
    }

    setmetatable(this, self)
    return this
end

function WaterMine:update(dt)
    -- self.y = self.y - VERTICAL_SPEED * dt

    if self.y == math.floor(self.map.player.y) and self.x == math.floor(self.map.player.x) then
        self.shouldExplode = true
    end
end

function WaterMine:render()
    love.graphics.draw( self.mine_sprite, self.x , self.y)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("x: " .. self.x .. "y: " .. self.y, self.x, self.y)
    love.graphics.print("x: " .. math.floor(self.map.player.x) .. "y: " .. math.floor(self.map.player.y), self.x, self.y + 10)
end

function WaterMine:destroy()
end