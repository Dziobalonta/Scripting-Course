-- Window parameters
local grid_X = 10
local grid_Y = 20
local blockSize = 30

-- time variables
local timer = 0
local dropSpeed = 0.5 

local gameState = "running" -- "running", "paused", "gameover",  "animating"
local score = 0

local drops = {}

local animTimer = 0

-- Board
local grid = {}

local currentPiece = {}
local spawnPiece_X = 4
local spawnPiece_Y = 1

-- Touch
local isTouching = false
local touch_X = 0
local touchTimer = 0
local hasSwiped = false
local swipeThreshold = 40 -- size of finger swipe to be registred as swipe

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
        {0, 0, 1, 0},
        {0, 1, 1, 0},
        {0, 1, 0, 0}
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
    },

    { -- Padding for rotating
        {1, 0, 0},
        {1, 1, 1},
        {0, 0, 0} 
    }
}

function saveGame()
    local data = "return {\n score = " .. score .. ",\n grid = {\n"
    for y = 1, grid_Y do
        data = data .. "  {" .. table.concat(grid[y], ",") .. "},\n"
    end
    data = data .. " }\n}"
    
    love.filesystem.write("savegame.lua", data)
end

function loadGame()
    if love.filesystem.getInfo("savegame.lua") then
        local chunk = love.filesystem.load("savegame.lua")
        local saveData = chunk()
        
        score = saveData.score
        grid = saveData.grid
        gameState = "running"
    end
end

function resetGame()
    for y = 1, grid_Y do
        for x = 1, grid_X do
            grid[y][x] = 0
        end
    end
    score = 0
    spawnPiece_X = 4
    spawnPiece_Y = 1
    gameState = "running"
end

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

        -- Sounds
    dropSound1 = love.audio.newSource("sfx/Lego Bricks Merge 1.wav", "static")
    dropSound2 = love.audio.newSource("sfx/Lego Bricks Merge 2.wav", "static")
    dropSound3 = love.audio.newSource("sfx/LegosDrop_BW.8953.wav", "static")
    drops = {dropSound1, dropSound2, dropSound3}

    clearSound = love.audio.newSource("sfx/YTDown_YouTube_Enderman-s-Teleport-Sound-Effect_Media_dOnc_jJMMU_007_128k.mp3", "static")
end

function love.draw()
    -- To draw a board - iterate over all blocks on the board
    for y = 1, grid_Y do
        for x = 1, grid_X do
            if grid[y][x] == 0 then
                -- Drawing empty blocks
                love.graphics.setColor(0.1, 0.1, 0.1)
                love.graphics.rectangle("fill", (x - 1) * blockSize, (y - 1) * blockSize, blockSize, blockSize)
                
                love.graphics.setColor(0.2, 0.2, 0.2)
                love.graphics.rectangle("line", (x - 1) * blockSize, (y - 1) * blockSize, blockSize, blockSize)
                
            elseif grid[y][x] == 1 then
                -- Normal color
                love.graphics.setColor(0.8, 0.8, 0.8)
                love.graphics.rectangle("fill", (x - 1) * blockSize, (y - 1) * blockSize, blockSize - 1, blockSize - 1)
                
            elseif grid[y][x] == 2 then
                -- Flashing red color
                if math.floor(animTimer * 10) % 2 == 0 then
                    love.graphics.setColor(1, 0, 0) -- Red
                else
                    love.graphics.setColor(1, 1, 1) -- White
                end
                love.graphics.rectangle("fill", (x - 1) * blockSize, (y - 1) * blockSize, blockSize, blockSize)
            end
        end
    end

    love.graphics.setColor(0, 0, 0, 0.8) 
    love.graphics.rectangle("fill", 0, 0, 100, 30)

    --  text
    love.graphics.setColor(1, 1, 1) 
    love.graphics.print("Score: " .. score, 10, 8)

    if gameState == "running" then
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

    -- UI
    if gameState == "paused" then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, grid_X * blockSize, grid_Y * blockSize)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("PAUSE", 105, 150, 0, 2, 2)
        
        love.graphics.rectangle("line", 80, 250, 140, 40)
        love.graphics.print("RESUME", 125, 262)

        love.graphics.rectangle("line", 80, 310, 140, 40)
        love.graphics.print("SAVE", 125, 322)

        love.graphics.rectangle("line", 80, 370, 140, 40)
        love.graphics.print("LOAD", 120, 382)
    end

    -- MENU GAME OVER
    if gameState == "gameover" then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, grid_X * blockSize, grid_Y * blockSize)
        
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("GAME OVER", 50, 200, 0, 2, 2)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", 80, 300, 140, 40)
        love.graphics.print("RETRY", 115, 312)

        love.graphics.rectangle("line", 80, 360, 140, 40)
        love.graphics.print("QUIT", 125, 372)
    end
end

function love.update(dt)

    if gameState == "animating" then
        animTimer = animTimer - dt
        
        -- when animation is done
        if animTimer <= 0 then
            local removedCounter = 0
            local y = grid_Y
            
            while y > 0 do
                if grid[y][1] == 2 then -- search for animating state
                
                    table.remove(grid, y)

                    local newRow = {}
                    
                    for i = 1, grid_X do
                        newRow[i] = 0
                    end

                    table.insert(grid, 1, newRow)
                    
                    removedCounter = removedCounter + 1
                else
                    y = y - 1
                end
            end

            if removedCounter > 0 then
                local added = removedCounter * 100
                score = score + added

                clearSound:clone():play()

                -- os.execute("cls")
                -- print("Score: " .. score  .. " (+" .. added .. ")")
            end

            spawnNextPiece()
        end
        
        return -- Stop updating when animating
    end

    if gameState ~= "running" then
        return
    end

    if isTouching then
        touchTimer = touchTimer + dt
    end

    local currentSpeed = dropSpeed

    if love.keyboard.isDown("down") or (isTouching and touchTimer >= 0.25 and not hasSwiped) then
        currentSpeed = 0.05
    end

    timer = timer + dt

    if timer >= currentSpeed then

        if canMove(currentPiece, spawnPiece_X, spawnPiece_Y + 1) then
            spawnPiece_Y = spawnPiece_Y + 1


            if love.keyboard.isDown("down") or (isTouching and touchTimer >= 0.25 and not hasSwiped) then
                score = score + 1
                -- os.execute("cls")
                -- print("Score: " .. score  .. " (+1)")
            end

        else
            lockPiece()
        end
        timer = 0
    end

end

function love.keypressed(key)

    if key == "escape" then
        if gameState == "running" then
            gameState = "paused"
        elseif gameState == "paused" then
            gameState = "running"
        end
    end

    if gameState ~= "running" then
        return -- ignore keys when paused
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

function love.mousepressed(x, y, button, istouch)
    if button == 1 then -- 1 means LMB
    
        if gameState == "paused" then
            -- checking coords on screen
            if x >= 80 and x <= 220 then
                -- Resume
                if y >= 250 and y <= 290 then
                    gameState = "running"
                -- Save
                elseif y >= 310 and y <= 350 then
                    saveGame()
                -- Load
                elseif y >= 370 and y <= 410 then
                    loadGame()
                end
            end
            
        elseif gameState == "gameover" then
            -- checking coords on screen
            if x >= 80 and x <= 220 then
                -- Reset
                if y >= 300 and y <= 340 then
                    resetGame()
                -- Quit
                elseif y >= 360 and y <= 400 then
                    love.event.quit()
                end
            end
        elseif gameState == "running" then
            -- Top Left tap - stops the game
            if x < 120 and y < 40 then
                gameState = "paused"
            else
                -- tracking touch/mouse/swie
                isTouching = true
                hasSwiped = false
                touchTimer = 0
                touch_X = x
            end
        end
    end
end

-- Function for swiping with finger - touch
function love.mousemoved(x, y, dx, dy, istouch)
    if gameState == "running" and isTouching then
        
        -- Swipe right
        if x - touch_X > swipeThreshold then
            if canMove(currentPiece, spawnPiece_X + 1, spawnPiece_Y) then
                spawnPiece_X = spawnPiece_X + 1
            end
            touch_X = x -- Reset
            hasSwiped = true
            
        -- Swipe left
        elseif touch_X - x > swipeThreshold then
            if canMove(currentPiece, spawnPiece_X - 1, spawnPiece_Y) then
                spawnPiece_X = spawnPiece_X - 1
            end
            touch_X = x
            hasSwiped = true
        end
        
    end
end

-- for roatating on tap
function love.mousereleased(x, y, button, istouch)
    if button == 1 and gameState == "running" then
        isTouching = false
       
        if not hasSwiped and touchTimer < 0.25 then
            local rot = rotatePiece(currentPiece)
            if canMove(rot, spawnPiece_X, spawnPiece_Y) then
                currentPiece = rot
            end
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

    local randID = love.math.random(1, #drops)
    drops[randID]:clone():play()

    if not checkForFull() then
        -- Choosing next shape 
        spawnNextPiece()
    end
    
end

function spawnNextPiece()
    spawnPiece_X = 4
    spawnPiece_Y = 1
    local randomID = love.math.random(1, #shapes)
    currentPiece = shapes[randomID]

    if not canMove(currentPiece, spawnPiece_X, spawnPiece_Y) then
       gameState = "gameover"
    else
        gameState = "running"
    end    
end

function checkForFull()
    local y = grid_Y
    local willAnimate = false

    while y > 0 do
        local isFull = true

        for x = 1, grid_X do
            if grid[y][x] == 0 then
                isFull = false
                break
            end    
        end

        if isFull then

            for x = 1, grid_X do
                grid[y][x] = 2
            end

            willAnimate = true

            y = y-1

        else
            y = y-1
            
        end
    end

    if willAnimate then
        gameState = "animating"
        animTimer = 0.5

    end

    return willAnimate
end