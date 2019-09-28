require 'animation'

RustyShip = {}
RustyShip.__index = RustyShip

function RustyShip:create(map, x, y)
    local this = {
        map = map,

        -- Texture from https://scottbarnett_lma.artstation.com/projects/GXeOL1
        texture = love.graphics.newImage('graphics/rusty-ship-scaled.png'),

        currentFrame = nil,
        animation = nil,

        x = x,
        y = y - 15,
    }

    this.animations = {
        ['idle'] = Animation:create({
            texture = this.texture,
            frames = {
                love.graphics.newQuad(32, 0, 76, 62, this.texture:getDimensions()),
                love.graphics.newQuad(160, 0, 76, 62, this.texture:getDimensions()),
                love.graphics.newQuad(32, 70, 76, 62, this.texture:getDimensions()),
                love.graphics.newQuad(160, 70, 76, 62, this.texture:getDimensions()),
            },
            interval = 0.5
        })
    }

    this.animation = this.animations['idle']
    this.currentFrame = this.animation:getCurrentFrame()

    setmetatable(this, self)
    return this
end

function RustyShip:update(dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
end

function RustyShip:render()
    love.graphics.draw(self.texture, self.currentFrame, self.x, self.y)
end

function RustyShip:destroy()
end