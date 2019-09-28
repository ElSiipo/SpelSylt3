require 'util'

Map = {}
Map.__index = Map

TILE_EMPTY = 29
TILE_OCEAN_FLOOR = 16

WATER_WAVE = 664
WATER_BODY = 697

CLOUD_TOP_LEFT = 661
CLOUD_TOP_MIDDLE = 662
CLOUD_TOP_RIGHT = 663
CLOUD_BOTTOM_LEFT = 694
CLOUD_BOTTOM_MIDDLE = 695
CLOUD_BOTTOM_RIGHT = 696

function Map:create()
    -- Music: www.bensound.com
    local music = love.audio.newSource('sound/bensound-deepblue.mp3', 'static')
    music:setLooping(true) --so it doesnt stop
    music:play()

    local this = {
        world_spritesheet = love.graphics.newImage('graphics/tiles.png'),

        tileWidth = 16,
        tileHeight = 16,
        mapWidth = 100,
        mapHeight = 28,
        waveHeight = 12,
        tiles = {},
        bubbles = {},
        waterMines = {},

        camX = 0,
        camY = -3,
    }

    this.rustyShip = RustyShip:create(this, this.waveHeight, 10)
    this.player = Player:create(this)

    -- generate a quad (individual frame/sprite) for each tile
    this.worldTileSprites = generateQuads(this.world_spritesheet, 16, 16)

    -- cache width and height of map in pixels
    this.mapWidthPixels = this.mapWidth * this.tileWidth
    this.mapHeightPixels = this.mapHeight * this.tileHeight

    -- sprite batch for efficient tile rendering
    this.spriteBatch = love.graphics.newSpriteBatch(this.world_spritesheet, this.mapWidth * this.mapHeight)

    setmetatable(this, self)

    -- first, fill map with empty tiles
    for y = 1, this.mapHeight do
        for x = 1, this.mapWidth do
            this:setTile(x, y, TILE_EMPTY)
        end
    end

    -- begin generating the terrain using vertical scan lines
    local currentWidth = 1
    while currentWidth < this.mapWidth do
        -- 2% chance to generate a cloud
        if currentWidth < this.mapWidth - 3 then
            if math.random(20) == 1 then
                local cloudStart = math.random(this.waveHeight / 2)

                this:setTile(currentWidth, cloudStart, CLOUD_TOP_LEFT)
                this:setTile(currentWidth, cloudStart + 1, CLOUD_BOTTOM_LEFT)
                this:setTile(currentWidth + 1, cloudStart, CLOUD_TOP_MIDDLE)
                this:setTile(currentWidth + 1, cloudStart + 1, CLOUD_BOTTOM_MIDDLE)
                this:setTile(currentWidth + 2, cloudStart, CLOUD_TOP_RIGHT)
                this:setTile(currentWidth + 2, cloudStart + 1, CLOUD_BOTTOM_RIGHT)
            end
        end

        -- Create water
        this:setTile(currentWidth, this.waveHeight / 2 - 2, WATER_WAVE)

        for currentHeight = this.waveHeight / 2 - 1, this.mapHeight do
            this:setTile(currentWidth, currentHeight, WATER_BODY)
        end

        -- Add WaterMines
        if math.random(10) == 1 then
            this:addWaterMine(WaterMine:create(
                this,
                currentWidth + math.random(-10, this.mapWidth * 10),
                this.mapHeight * 4 + math.random(-this.mapHeight * 2, this.mapHeight * 3)))
        end

        this:setTile(currentWidth, this.mapHeight / 2 + 1, TILE_OCEAN_FLOOR)

        currentWidth = currentWidth + 1
    end

    -- create sprite batch from tile quads
    for y = 1, this.mapHeight do
        for x = 1, this.mapWidth do
            this.spriteBatch:add(this.worldTileSprites[this:getTile(x, y)],
                (x - 1) * this.tileWidth, (y - 1) * this.tileHeight)
        end
    end

    return this
end

function Map:collides(tile)
    local collidables = {
        WATER_WAVE, TILE_OCEAN_FLOOR,
    }

    -- iterate and return true if our tile type matches
    for _, v in ipairs(collidables) do
        if tile == v then
            return true
        end
    end

    return false
end

function Map:addBubble(bubble)
    table.insert(self.bubbles, bubble)
    return bubble
end

function Map:addWaterMine(waterMine)
    table.insert(self.waterMines, waterMine)
    return waterMine
end

-- function to update camera offset based on player coordinates
function Map:update(dt)
    self.rustyShip:update(dt)
    self.player:update(dt)

    for i = #self.bubbles, 1, -1 do
        local currentBubble = self.bubbles[i]
        currentBubble:update(dt)

        if (currentBubble.shouldBurst) then
            table.remove(self.bubbles, i)
            currentBubble:destroy()
        end
    end

    for i = #self.waterMines, 1, -1 do
        local currentWaterMine = self.waterMines[i]
        currentWaterMine:update(dt)

        if (currentWaterMine.shouldExplode) then
            table.remove(self.waterMines, i)
            currentWaterMine:destroy()
            self.player:destroy()
        end
    end

    self.camX = math.max(0, math.min(self.player.x - virtualWidth / 2,
        math.min(self.mapWidthPixels - virtualWidth, self.player.x)))
end

function Map:render()
    self.rustyShip:render()
    love.graphics.draw(self.spriteBatch)

    self.player:render()

    for _, bubble in ipairs(self.bubbles) do
        bubble:render()
    end

    for _, waterMine in ipairs(self.waterMines) do
        waterMine:render()
    end
end

function Map:tileAt(x, y)
    return self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
end

-- returns an integer value for the tile at a given x-y coordinate
function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

-- sets a tile at a given x-y coordinate to an integer value
function Map:setTile(x, y, tile)
    self.tiles[(y - 1) * self.mapWidth + x] = tile
end