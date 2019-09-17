
Bubbles = {}
Bubbles.__index = Bubbles


local VERTICAL_SPEED = 40

function Bubbles:create(map)
    local this = {
        map = map,

        x = 0,
        y = 0,

        width = 32,
        height = 16,

        deltaTime = 0
    }

    this.y = map.tileHeight * ((map.mapHeight - 2) / 2) - this.height
    this.x = map.tileWidth * 10
    
    setmetatable(this, self)
    return this
end

function Bubbles:update(dt)
    self.y = self.y - 0.4
    
    -- self.deltaTime = self.deltaTime + dt

    -- if self.deltaTime > 2 then
        if self.map:collides(self.map:tileAt(self.x, self.y - 1)) or
            self.map:collides(self.map:tileAt(self.x, self.y + self.height - 1)) then
            self.y = self.map.player.y - self.height / 2
            self.x = self.map.player.x
        end

    --     self.deltaTime = 0
    -- end
end

function Bubbles:render()
    love.graphics.setColor(1, 1, 1)

    love.graphics.circle("line", self.x + self.width - 3, self.y + 3, 1, 10)
    love.graphics.circle("line", self.x + self.width - 1, self.y - 3, 1, 10)
    love.graphics.circle("line", self.x + self.width + 3, self.y, 3, 10)
end

-- function isCollidingAbove()
--     if self.map:collides(self.map:tileAt(self.x, self.y - 1)) or
--         self.map:collides(self.map:tileAt(self.x, self.y + self.height - 1)) then
--             return true
--             -- Make bubbles pop / disappear

--             -- self.dy = 0
--             -- self.y = self.y + (self.y % 16)
--     end

--     return false
-- end