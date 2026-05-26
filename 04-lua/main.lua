-- Window parameters
local grid_X = 10
local grid_Y = 20
local blockSize = 30

-- time variables
local timer = 0
local dropSpeed = 0.5 

-- Board
local grid = {}


local currentPiece = {}
local spawnPiece_X = 4
local spawnPiece_Y = 1

-- Pieces
local shapes = {
    {
        {1, 1},
        {1, 1}
    },

    { -- Padding for rotating
        {0, 0, 0, 0},
        {1, 1, 1, 1},
        {0, 0, 0, 0},
        {0, 0, 0, 0}
    },

    { -- Padding for rotating
        {0, 1, 0},
        {1, 1, 1},
        {0, 0, 0}
    },

    { -- Padding for rotating
        {0, 0, 1},
        {1, 1, 1},
        {0, 0, 0} 
    }
}

function love.load()

    love.window.setMode(grid_X * blockSize, grid_Y * blockSize)
    love.window.setTitle("Tetris")

    -- Creating a Board with nothing 
    for y = 1, grid_Y do
        grid[y] = {}
        for x = 1, grid_X do
            grid[y][x] = 0
        end
    end

    -- Choosing first shape
    local randomID = love.math.random(1, #shapes)
    currentPiece = shapes[randomID]
end

function love.draw()
    -- To draw a board - iterate over all blocks on the board
    for y = 1, grid_Y do
        for x = 1, grid_X do
            if grid[y][x] == 0 then
                -- Drawing a blocks with lineout to better see the size
                love.graphics.setColor(0.1, 0.1, 0.1)
                love.graphics.rectangle("fill", (x - 1) * blockSize, (y - 1) * blockSize, blockSize, blockSize)
                
                love.graphics.setColor(0.2, 0.2, 0.2)
                love.graphics.rectangle("line", (x - 1) * blockSize, (y - 1) * blockSize, blockSize, blockSize)
            else
                -- white fill for easy debug when something goes wrong
                love.graphics.setColor(0.8, 0.8, 0.8)
                love.graphics.rectangle("fill", (x - 1) * blockSize, (y - 1) * blockSize, blockSize - 1, blockSize - 1)
            end
        end
    end


    for y = 1, #currentPiece do
        for x = 1, #currentPiece[y] do
            if currentPiece[y][x] == 1 then
                -- Calculate location on the screen
                local screen_X = (spawnPiece_X + x - 2) * blockSize
                local screen_Y = (spawnPiece_Y + y - 2) * blockSize

                love.graphics.setColor(0.2, 0.6, 1.0)
                love.graphics.rectangle("fill", screen_X, screen_Y, blockSize, blockSize)

                love.graphics.setColor(0.8, 0.8, 0.8)
                love.graphics.rectangle("line", screen_X, screen_Y, blockSize, blockSize)
            end
        end
    end
end

function love.update(dt)
    local currentSpeed = dropSpeed

    -- making the interval smaller = falling faster
    if love.keyboard.isDown("down") then
        currentSpeed = 0.05
    end

    timer = timer + dt

    if timer >= currentSpeed then
        spawnPiece_Y = spawnPiece_Y + 1
        timer = 0
    end

end

function love.keypressed(key)

    if key == "up" then
        currentPiece = rotatePiece(currentPiece)
    end

    if key == "left" then
        spawnPiece_X = spawnPiece_X - 1
    end

    if key == "right" then
        spawnPiece_X = spawnPiece_X + 1
    end

end

function rotatePiece(piece)
    local rotated =  {}
    local size = #piece

    for y = 1, size do
        rotated[y] = {} -- Create new row before starting to write to it
        for x = 1, size do
            rotated[y][x] = piece[size - x + 1][y]
        end 
    end

    return rotated
end