-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
-- Your code here
-- the world needs to be devided into a grid
-- the grid size needs to be dynamic
-- so we need a marker for the highest and lowest occupied squares
--
-- make a bunch of ants start at home
-- the ants can start when I click the space bar
--
-- ants drop a pheromone trail
-- a blue one dropped when exploring can be followed back home
-- a red one dropped when carrying food can be followed back to the food
-- pheromone should fade and spread out in random directions
--
-- the chances of seeing a pheromone are preportional to the fadedness
-- when following the trail it should twards pheromone at a small distance
-- but when there is a lot of pheromone it should twards the the average direction
--
-- the ants all have targets
-- the targets will be a location or a direction
-- compute all the posible targets in order of least to most important
-- ants should slow down when approaching a target location
-- and when the target direction is way different from the current direction
--
local backGroup = display.newGroup()
local backGround = display.newRect(backGroup, display.contentCenterX, display.contentCenterY,
    display.actualContentWidth, display.actualContentHeight)
backGround:setFillColor(1, 1, 1)

local grid = {}
local gridBoxOrigin = {
    x = 0,
    y = 0
}
local gridBoxSize = 20
local gridBounds = {
    minX = 0,
    maxX = 0,
    minY = 0,
    maxY = 0
}
local centerBoxX = math.floor((display.contentCenterX - gridBoxOrigin.x) / gridBoxSize)
local centerBoxY = math.floor((display.contentCenterY - gridBoxOrigin.y) / gridBoxSize)
local gridOrigin = {}
gridOrigin.x = centerBoxX
gridOrigin.y = centerBoxY
print(gridOrigin.x, gridOrigin.y)
local testBorder = display.newRect(backGroup, display.contentCenterX, display.contentCenterY,
    (gridBounds.maxX - gridBounds.minX) * gridBoxSize, (gridBounds.maxY - gridBounds.minY) * gridBoxSize)
testBorder:setFillColor(0, 0, 0.5, 0.5)
local addToGrid = function(object)
    local gridCords = {}
    gridCords.x = math.floor((object.x - gridBoxOrigin.x) / gridBoxSize + 0.5)
    gridCords.y = math.floor((object.y - gridBoxOrigin.y) / gridBoxSize + 0.5)
    local adjustedGridCords = {}
    adjustedGridCords.x = gridCords.x - gridOrigin.x + 1
    adjustedGridCords.y = gridCords.y - gridOrigin.y + 1
    print("addToGrid", adjustedGridCords.x, adjustedGridCords.y)
    -- check bounds
    if (adjustedGridCords.x < 1) then
        local intertAmount = 1 - adjustedGridCords.x
        gridOrigin.x = gridOrigin.x - intertAmount
        for i = 1, intertAmount do
            table.insert(grid, 1, {})
            for j = 1, gridBounds.maxY do
                grid[1][#grid[1] + 1] = {}
            end
        end
        gridBounds.maxX = gridBounds.maxX + intertAmount
    end
    if (adjustedGridCords.y < 1) then
        local intertAmount = 1 - adjustedGridCords.y
        gridOrigin.y = gridOrigin.y - intertAmount
        for i = 1, intertAmount do
            for j = 1, gridBounds.maxX do
                table.insert(grid[j], adjustedGridCords.y, {})
            end
        end
        gridBounds.maxY = gridBounds.maxY + intertAmount
    end
    if (adjustedGridCords.x > gridBounds.maxX) then
        local intertAmount = adjustedGridCords.x - gridBounds.maxX
        for i = 1, intertAmount do
            grid[#grid + 1] = {}
            for j = 1, gridBounds.maxY do
                grid[#grid][#grid[#grid] + 1] = {}
            end
        end
        gridBounds.maxX = adjustedGridCords.x
    end
    if (adjustedGridCords.y > gridBounds.maxY) then
        local intertAmount = adjustedGridCords.y - gridBounds.maxY
        for i = 1, intertAmount do
            for j = 1, gridBounds.maxX do
                grid[j][#grid[j] + 1] = {}
            end
        end
        gridBounds.maxY = gridCords.y
    end
    local test = display.newRect(gridCords.x * gridBoxSize, gridCords.y * gridBoxSize, gridBoxSize, gridBoxSize)
    test:setFillColor(0.8, 0.8, 0.6)
    timer.performWithDelay(100, function()
        display.remove(test)
    end)
end
local removeFromGrid = function(object, gridCordsX, gridCordsY)
    if (grid[gridCordsX] and grid[gridCordsX][gridCordsY]) then
        for i = 1, #grid[gridCordsX][gridCordsY] do
            if (grid[gridCordsX][gridCordsY][i] == object) then
                table.remove(grid[gridCordsX][gridCordsY], i)
                break
            end
        end
        -- check if it was on the outside collumn
        if (gridCordsX == 0) then
            -- trim the grid
            for row = 1, #grid do
                -- check if that row is now empty
                local isEmpty = true
                for col = 1, #grid[row] do
                    if (grid[row][col]) then
                        if (#grid[row][col] > 0) then
                            isEmpty = false
                            break
                        end
                    end
                end
                if (isEmpty) then
                    table.remove(grid, row)
                else
                    break
                end
            end
        end
        if (gridCordsX == gridBounds.maxX) then
            -- trim the grid
            for row = #grid, 1, -1 do
                -- check if that row is now empty
                local isEmpty = true
                for col = 1, #grid[row] do
                    if (grid[row][col]) then
                        if (#grid[row][col] > 0) then
                            isEmpty = false
                            break
                        end
                    end
                end
                if (isEmpty) then
                    table.remove(grid, row)
                    gridBounds.maxX = row - 1
                else
                    break
                end
            end
        end
        if (gridCordsY == 0) then
            -- trim the grid
            for col = 1, #grid[1] do
                -- check if that row is now empty
                local isEmpty = true
                for row = 1, #grid do
                    if (grid[row][col]) then
                        if (#grid[row][col] > 0) then
                            isEmpty = false
                            break
                        end
                    end
                end
                if (isEmpty) then
                    table.remove(grid[gridCordsX], col)
                else
                    break
                end
            end
        end
        if (gridCordsY == gridBounds.maxY) then
            -- trim the grid
            for col = #grid[1], 1, -1 do
                -- check if that row is now empty
                local isEmpty = true
                for row = 1, #grid do
                    if (grid[row][col]) then
                        if (#grid[row][col] > 0) then
                            isEmpty = false
                            break
                        end
                    end
                end
                if (isEmpty) then
                    table.remove(grid[gridCordsX], col)
                    gridBounds.maxY = col - 1
                else
                    break
                end
            end
        end
    end
end
local updateInGrid = function(object)
    -- take it out of the old box and put it in the new
    local gridCords = {}
    local adjustedGridCords = {}
    if (object.oldPos ~= nil) then
        -- find the box it was in
        gridCords.x = math.floor((object.oldPos.x - gridBoxOrigin.x) / gridBoxSize + 0.5)
        gridCords.y = math.floor((object.oldPos.y - gridBoxOrigin.y) / gridBoxSize + 0.5)
        adjustedGridCords.x = gridCords.x - gridOrigin.x + 1
        adjustedGridCords.y = gridCords.y - gridOrigin.y + 1
        -- if the it was in that box then remove it
        print("removeFromGrid", adjustedGridCords.x, adjustedGridCords.y)
        print(#grid, #grid[adjustedGridCords.x])
        removeFromGrid(object, adjustedGridCords.x, adjustedGridCords.y)
    end
    -- put it in the new box
    gridCords.x = math.floor((object.x - gridBoxOrigin.x) / gridBoxSize + 0.5)
    gridCords.y = math.floor((object.y - gridBoxOrigin.y) / gridBoxSize + 0.5)
    adjustedGridCords.x = gridCords.x - gridOrigin.x + 1
    adjustedGridCords.y = gridCords.y - gridOrigin.y + 1
    addToGrid(object)
    testBorder.width, testBorder.height = (gridBounds.maxX - gridBounds.minX) * gridBoxSize,
        (gridBounds.maxY - gridBounds.minY) * gridBoxSize
end

local home = display.newCircle(backGroup, display.contentCenterX, display.contentCenterY, 20)
home.oldPos = {}
home:setFillColor(0.3, 0, 0.1)
addToGrid(home)
local mouse = function(event)
    home.oldPos.x = home.x
    home.oldPos.y = home.y
    home.x = event.x
    home.y = event.y
    updateInGrid(home)
end

Runtime:addEventListener("mouse", mouse)
