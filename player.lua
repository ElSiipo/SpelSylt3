require 'animation'

Player = {}
Player.__index = Player

local PADDEL_SPEED = 50
local VERTICAL_SPEED = 40

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
        bubbles_texture = love.graphics.newImage('graphics/bubbles_spritesheet_Scaled.png'),

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
        ['swimming'] = Animation:create({
            texture = this.texture,
            frames = {
                love.graphics.newQuad(34, 0, 32, 16, this.texture:getDimensions()),
                love.graphics.newQuad(66, 0, 32, 16, this.texture:getDimensions()),
                love.graphics.newQuad(98, 0, 32, 16, this.texture:getDimensions()),
                love.graphics.newQuad(66, 0, 32, 16, this.texture:getDimensions()),
            },
            interval = 0.15
        }),
        ['bubbles'] = Animation:create({
            bubbleTexture = this.bubbles_texture,
            bubbleFrames = {
                love.graphics.newQuad(16, 0, 16, 16, this.bubbles_texture:getDimensions()),
                love.graphics.newQuad(32, 0, 16, 16, this.bubbles_texture:getDimensions()),
                love.graphics.newQuad(48, 0, 16, 16, this.bubbles_texture:getDimensions()),
                love.graphics.newQuad(0, 16, 16, 16, this.bubbles_texture:getDimensions()),
            },
            interval = 0.15
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
                this.dx = -PADDEL_SPEED
                this.dy = 0
                this.state = 'swimming'
                this.animations['swimming']:restart()
                this.animation = this.animations['swimming']
            elseif love.keyboard.isDown('right') then
                direction = 'right'
                this.dx = PADDEL_SPEED
                this.dy = 0
                this.state = 'swimming'
                this.animations['swimming']:restart()
                this.animation = this.animations['swimming']
            elseif love.keyboard.isDown('up') then
                direction = 'up'
                this.dx = 0
                this.dy = -VERTICAL_SPEED
                this.state = 'swimming'
                this.animations['swimming']:restart()
                this.animation = this.animations['swimming']
            elseif love.keyboard.isDown('down') then
                direction = 'down'
                this.dx = 0
                this.dy = VERTICAL_SPEED
                this.state = 'swimming'
                this.animations['swimming']:restart()
                this.animation = this.animations['swimming']
            end
        end,
        ['swimming'] = function(dt)
            -- keep track of input to switch movement while swimming, or reset
            -- to idle if we're not moving
            if love.keyboard.isDown('left') then
                direction = 'left'
                this.dx = -PADDEL_SPEED
                this.dy = 0
            elseif love.keyboard.isDown('right') then
                direction = 'right'
                this.dx = PADDEL_SPEED
                this.dy = 0
            elseif love.keyboard.isDown('up') then
                direction = 'up'
                this.dx = 0
                this.dy = -VERTICAL_SPEED
            elseif love.keyboard.isDown('down') then
                direction = 'down'
                this.dx = 0
                this.dy = VERTICAL_SPEED
            else
                this.dx = 0
                this.dy = 0
                this.state = 'idle'
                this.animation = this.animations['idle']
            end

            this:checkCollisionAbove()
            this:checkCollisionRight()
            this:checkCollisionLeft()
            this:checkCollisionBelow()
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
    self.y = self.y + self.dy * dt
end

function Player:checkCollisionAbove()
    if self.map:collides(self.map:tileAt(self.x, self.y - 1)) or
        self.map:collides(self.map:tileAt(self.x, self.y + self.height - 1)) then
            self.dy = 0
            self.y = self.y + (self.y % self.map.tileHeight)
    end
end

function Player:checkCollisionBelow()
    if self.map:collides(self.map:tileAt(self.x, self.y + 1)) or
        self.map:collides(self.map:tileAt(self.x, self.y + self.height + 1)) then
            self.dy = 0
            self.y = self.y - 1
    end
end

function Player:checkCollisionLeft()
    if self.dx < 0 then
        -- check if there's a tile directly beneath us
        if self.map:collides(self.map:tileAt(self.x - 1, self.y)) or
            self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 1)) then
            -- if so, reset velocity and position and change state
            self.dx = 0
            local xmod = (self.x - 1) % self.map.tileWidth
            local offset = self.map.tileWidth - xmod
            self.x = math.floor(self.x - 1 + offset)
        end
    end
end

-- checks two tiles to our right to see if a collision occurred
function Player:checkCollisionRight()
    if self.dx > 0 then
        -- check if there's a tile directly beneath us
        if self.map:collides(self.map:tileAt(self.x + self.width, self.y)) or
            self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then
            -- if so, reset velocity and position and change state
            self.dx = 0
            self.x = math.floor(self.x - (self.x % self.map.tileWidth))
        end
    end
end

function Player:render()
    local scaleX
    local rotation

    -- set negative x scale factor if facing left, which will flip the sprite
    -- when applied
    if direction == 'right' then
        scaleX = 1
    elseif direction == 'left' then
        scaleX = -1
    end

    if direction == 'up' then
        rotation = -30
    elseif direction == 'down' then
        rotation = 30
    else
        rotation = 0
    end

    -- draw sprite with scale factor and offsets
    love.graphics.draw(self.texture, self.currentFrame, self.x + self.xOffset,
        self.y + self.yOffset, math.rad(rotation), scaleX, 1, self.xOffset, self.yOffset)

    -- if math.random(5) == 1 then
    --     love.graphics.draw(self.texture, self.currentFrame, self.x + self.xOffset,
    --         self.y + self.yOffset, math.rad(rotation), scaleX, 1, self.xOffset, self.yOffset)
    -- end
end