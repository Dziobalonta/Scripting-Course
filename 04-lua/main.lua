-- Window parameters
local grid_X = 10
local grid_Y = 20
local blockSize = 30

-- time variables
local timer = 0
local dropSpeed = 0.5 

local gameOver = false

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
        {0, 1, 0, 0},
        {0, 1, 1, 0},
        {0, 0, 1, 0}
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

    if gameOver then
        return
    end

    local currentSpeed = dropSpeed

    -- making the interval smaller = falling faster
    if love.keyboard.isDown("down") then
        currentSpeed = 0.05
    end

    timer = timer + dt

    if timer >= currentSpeed then

        if canMove(currentPiece, spawnPiece_X, spawnPiece_Y + 1) then
            spawnPiece_Y = spawnPiece_Y + 1

        else
            lockPiece()
        end
        timer = 0
    end

end

function love.keypressed(key)

    if gameOver then
        return
    end

    if key == "up" then
        local rot = rotatePiece(currentPiece)

        if canMove(rot, spawnPiece_X, spawnPiece_Y) then
            currentPiece = rot
        end
    end

    if key == "left" then
        local offseted = spawnPiece_X - 1

        if canMove(currentPiece, spawnPiece_X - 1, spawnPiece_Y) then
            spawnPiece_X = offseted
        end
    end

    if key == "right" then
        local offseted = spawnPiece_X + 1

        if canMove(currentPiece, spawnPiece_X + 1, spawnPiece_Y) then
            spawnPiece_X = offseted
        end
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
-- checks next X and Y for a given piece
function canMove(piece, next_X, next_Y)

    for y = 1, #piece do
        for x = 1, #piece[y] do
            if piece[y][x] == 1 then

                local test_X = next_X + x - 1
                local test_Y = next_Y + y - 1

                -- check walls and floor
                if test_X < 1 or test_X > grid_X or test_Y > grid_Y then
                    return false 
                end


                -- check for older pieces
                if test_Y > 0 and grid[test_Y][test_X] ~= 0 then
                    return false
                end

            end
        end
    end
    return true
end

function lockPiece()

    for y = 1, #currentPiece do
        for x = 1, #currentPiece[y] do
            if currentPiece[y][x] == 1 then

                local final_X = spawnPiece_X + x - 1
                local final_Y = spawnPiece_Y + y - 1

                -- write to a board
                if final_Y > 0 then
                    grid[final_Y][final_X] = 1
                end
            end
        end
    end

    checkForFull()

    -- Choosing next shape
    spawnPiece_X = 4
    spawnPiece_Y = 1
    local randomID = love.math.random(1, #shapes)
    currentPiece = shapes[randomID]

    if not canMove(currentPiece, spawnPiece_X, spawnPiece_Y) then
        gameOver = true
    end
    
end

function checkForFull()
    local y = grid_Y

    while y > 0 do
        local isFull = true

        for x = 1, grid_X do
            if grid[y][x] == 0 then
                isFull = false
                break
            end    
        end

        if isFull then
            table.remove(grid, y)

            local newRow = {}
            for i = 1, grid_X do
                newRow[i] = 0
            end

            table.insert(grid, 1, newRow)

        else
            y = y-1
            
        end
    end
    
end