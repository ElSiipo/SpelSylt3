--[[
    Contains tile data and necessary code for rendering a tile map to the
    screen.
]]

require 'Util'

-- object-oriented boilerplate; establish Map's "prototype"
Map = {}
Map.__index = Map

-- TILE_BRICK = 1
TILE_EMPTY = 29
TILE_OCEAN_FLOOR = 16
-- TILE_QUESTION = 25

WATER_WAVE = 664
WATER_BODY = 697

-- cloud tiles
CLOUD_TOP_LEFT = 661
CLOUD_TOP_MIDDLE = 662
CLOUD_TOP_RIGHT = 663
CLOUD_BOTTOM_LEFT = 694
CLOUD_BOTTOM_MIDDLE = 695
CLOUD_BOTTOM_RIGHT = 696

-- a speed to multiply delta time to scroll map; smooth value
local scrollSpeed = 124

-- constructor for our map object
function Map:create()

    -- Music: www.bensound.com
    local music = love.audio.newSource('sound/bensound-deepblue.mp3', 'static')
    music:setLooping(true) --so it doesnt stop
    music:play()

    local this = {
        -- our texture containing all sprites
        world_spritesheet = love.graphics.newImage('graphics/tiles.png'),

        tileWidth = 16,
        tileHeight = 16,
        mapWidth = 100,
        mapHeight = 28,
        waveHeight = 12,
        tiles = {},

        -- camera offsets
        camX = 0,
        camY = -3,
    }

    -- associate player with map
    this.player = Player:create(this)

    -- generate a quad (individual frame/sprite) for each tile
    this.worldTileSprites = generateQuads(this.world_spritesheet, 16, 16)

    -- cache width and height of map in pixels
    this.mapWidthPixels = this.mapWidth * this.tileWidth
    this.mapHeightPixels = this.mapHeight * this.tileHeight

    -- sprite batch for efficient tile rendering
    this.spriteBatch = love.graphics.newSpriteBatch(this.world_spritesheet, this.mapWidth * this.mapHeight)

    -- more OO boilerplate so we have access to class functions
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
        -- make sure we're 3 tiles from edge at least
        if currentWidth < this.mapWidth - 3 then
            if math.random(20) == 1 then
                -- choose a random vertical spot above where blocks/pipes generate
                local cloudStart = math.random(this.waveHeight / 2 - 6)

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

-- function to update camera offset based on player coordinates
function Map:update(dt)
    self.player:update(dt)

    -- keep camera's X coordinate following the player, preventing camera from
    -- scrolling past 0 to the left and the map's width
    self.camX = math.max(0, math.min(self.player.x - virtualWidth / 2,
        math.min(self.mapWidthPixels - virtualWidth, self.player.x)))
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

-- renders our map to the screen, to be called by main's render
function Map:render()
    -- replace tile-by-tile rendering with spriteBatch draw call
    love.graphics.draw(self.spriteBatch)
    self.player:render()
end
