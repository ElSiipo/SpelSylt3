require 'animation'

Seaweed = {}
Seaweed.__index = Seaweed

function Seaweed:create(map, x, y)
    local this = {
        map = map,

        -- Texture from http://rosprites.blogspot.com/2010/12/monsters-octopus-kraken-and-much-more.html
        texture = love.graphics.newImage('graphics/Seaweed_noBG.png'),

        currentFrame = nil,
        animation = nil,

        x = x,
        y = y,
    }

    this.animations = {
        ['idle'] = Animation:create({
            texture = this.texture,
            frames = {
                love.graphics.newQuad(0, 0, 60, 78, this.texture:getDimensions()),
                love.graphics.newQuad(60, 0, 60, 78, this.texture:getDimensions()),
                love.graphics.newQuad(120, 0, 60, 78, this.texture:getDimensions()),
                love.graphics.newQuad(180, 0, 60, 78, this.texture:getDimensions()),
                love.graphics.newQuad(240, 0, 60, 78, this.texture:getDimensions()),
                love.graphics.newQuad(300, 0, 60, 78, this.texture:getDimensions()),
                love.graphics.newQuad(360, 0, 60, 78, this.texture:getDimensions()),
                love.graphics.newQuad(420, 0, 60, 78, this.texture:getDimensions()),

                -- love.graphics.newQuad(0, 78, 60, 78, this.texture:getDimensions()),
                -- love.graphics.newQuad(60, 78, 60, 78, this.texture:getDimensions()),
                -- love.graphics.newQuad(120, 78, 60, 78, this.texture:getDimensions()),
                -- love.graphics.newQuad(180, 78, 60, 78, this.texture:getDimensions()),
                -- love.graphics.newQuad(240, 78, 60, 78, this.texture:getDimensions()),
                -- love.graphics.newQuad(300, 78, 60, 78, this.texture:getDimensions()),
                -- love.graphics.newQuad(360, 78, 60, 78, this.texture:getDimensions()),
                -- love.graphics.newQuad(420, 78, 60, 78, this.texture:getDimensions()),
            },
            interval = 0.2
        })
    }

    this.animation = this.animations['idle']
    this.currentFrame = this.animation:getCurrentFrame()

    setmetatable(this, self)
    return this
end

function Seaweed:update(dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
end

function Seaweed:render()
    love.graphics.draw(self.texture, self.currentFrame, self.x, self.y)
end

function Seaweed:destroy()
end