Player = {}
Player.__index = Player

function Player:create(map)
    local this = {
        x = 0,
        y = 0,
        width = 32,
        height = 16,
        xOffset = 16,
        yOffset = 8,
        map = map,
        texture = love.graphics.newImage('graphics/heroScaled.png'),

        frames = {},
        currentFrame = nil,
        state = 'idle',
        direction = 'left',

        dx = 0,
        dy = 0
    }

    this.y = map.tileHeight * ((map.mapHeight - 2) / 2) - this.height
    this.x = map.tileWidth * 10

    this.frames = {
        love.graphics.newQuad(0,0,32,16, this.texture:getDimensions())
    }

    this.currentFrame = this.frames[1]

    this.behaviours = {
        ['idle'] = function(dt)
            if love.keyboard.wasPressed('left') then
                direction = 'left'
            end
            if love.keyboard.wasPressed('right') then
                direction = 'right'
            end
        end
    }

    setmetatable(this, self)
    return this
end

function Player:update(dt)
    self.behaviours[self.state](dt)
end

function Player:render()
    local scaleX

    -- set negative x scale factor if facing left, which will flip the sprite
    -- when applied
    if direction == 'right' then
        scaleX = 1
    else
        scaleX = -1
    end

    -- draw sprite with scale factor and offsets
    love.graphics.draw(self.texture, self.currentFrame, self.x + self.xOffset,
        self.y + self.yOffset, 0, scaleX, 1, self.xOffset, self.yOffset)
end