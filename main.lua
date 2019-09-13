-- global key-handling
love.keyboard.keysPressed = {}
love.keyboard.keysReleased = {}

-- virtual resolution library
push = require 'push'

require 'Map'
require 'Player'

-- virtual resolution
virtualWidth = 432
virtualHeight = 243

-- actual window resolution
windowWidth = 1280
windowHeight = 720


-- our map data
map = Map:create()

-- function called at start of game to load assets
function love.load()
    -- Music: www.bensound.com
    local music = love.audio.newSource( 'sound/bensound-deepblue.mp3', 'static' )
    music:setLooping( true ) --so it doesnt stop
    music:play()

    love.graphics.setDefaultFilter('nearest', 'nearest')

    local sprite = love.graphics.newImage('graphics/heroScaled.png')
    x = virtualWidth / 2 - sprite:getWidth() / 2
    y = virtualHeight / 2 - sprite:getHeight() / 2

    push:setupScreen(virtualWidth, virtualHeight, windowWidth, windowHeight, {
        fullscreen = false,
        resizable = true
    })
end

-- called whenever window is resized
function love.resize(w, h)
    push:resize(w, h)
end

-- global key pressed function
function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end

-- global key released function
function love.keyboard.wasReleased(key)
    if (love.keyboard.keysReleased[key]) then
        return true
    else
        return false
    end
end

-- called whenever a key is pressed
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    love.keyboard.keysPressed[key] = true
end

-- called whenever a key is released
function love.keyreleased(key)
    love.keyboard.keysReleased[key] = true
end

-- called every frame, with dt passed in as delta in time since last frame
function love.update(dt)
    map:update(dt)

    -- reset all keys pressed and released this frame
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end

-- called each frame, used to render to the screen
function love.draw()
    -- begin virtual resolution drawing
    push:apply('start')

    -- clear screen, set color
    love.graphics.setColor( 153, 204, 255 )

    -- renders our map object onto the screen
    love.graphics.translate(math.floor(-map.camX), math.floor(-map.camY))
    map:render()

    -- end virtual resolution
    push:apply('end')
end