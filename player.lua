require 'animation'

Player = {}
Player.__index = Player

local WALKING_SPEED = 140

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

        currentFrame = nil,
        animation = nil,

        state = 'idle',
        direction = 'right',

        dx = 0,
        dy = 0
    }

    this.y = map.tileHeight * ((map.mapHeight - 2) / 2) - this.height
    this.x = map.tileWidth * 10

    this.animations = {
        ['idle'] = Animation:create({
            texture = this.texture,
            frames = {
                love.graphics.newQuad(0, 0, 32, 16, this.texture:getDimensions())
            }
        }),
        ['walking'] = Animation:create({
            texture = this.texture,
            frames = {
                love.graphics.newQuad(34, 0, 32, 16, this.texture:getDimensions()),
                love.graphics.newQuad(66, 0, 32, 16, this.texture:getDimensions()),
                love.graphics.newQuad(98, 0, 32, 16, this.texture:getDimensions()),
                love.graphics.newQuad(66, 0, 32, 16, this.texture:getDimensions()),
            },
            interval = 0.07
        })
    }

    -- initialize animation and current frame we should render
    this.animation = this.animations['idle']
    this.currentFrame = this.animation:getCurrentFrame()

    this.behaviours = {
        ['idle'] = function(dt)
            -- begin moving if left or right is pressed
            if love.keyboard.isDown('left') then
                direction = 'left'
                this.dx = -WALKING_SPEED
                this.state = 'walking'
                this.animations['walking']:restart()
                this.animation = this.animations['walking']
            elseif love.keyboard.isDown('right') then
                direction = 'right'
                this.dx = WALKING_SPEED
                this.state = 'walking'
                this.animations['walking']:restart()
                this.animation = this.animations['walking']
            end
        end,
        ['walking'] = function(dt)
            -- keep track of input to switch movement while walking, or reset
            -- to idle if we're not moving
            if love.keyboard.isDown('left') then
                direction = 'left'
                this.dx = -WALKING_SPEED
            elseif love.keyboard.isDown('right') then
                direction = 'right'
                this.dx = WALKING_SPEED
            else
                this.dx = 0
                this.state = 'idle'
                this.animation = this.animations['idle']
            end
        end
    }

    setmetatable(this, self)
    return this
end

function Player:update(dt)
    self.behaviours[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
    self.x = self.x + self.dx * dt
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