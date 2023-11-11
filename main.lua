-- the grid system
local grid = {}
local gridBoxSize = 20
local gridLocalOrigin = {
    x = 0,
    y = 0
}
local getGridCoordinate = function(x, y)
    local gridCords = {}
    gridCords.x = math.floor((x - gridLocalOrigin.x) / gridBoxSize)
    gridCords.y = math.floor((y - gridLocalOrigin.y) / gridBoxSize)
    return gridCords
end
local addToGrid = function(object)
    -- witch grid box would it fall into
    local gridCords = getGridCoordinate(object.x, object.y)
    -- gridCords.x = math.floor((object.x - gridLocalOrigin.x) / gridBoxSize)
    -- gridCords.y = math.floor((object.y - gridLocalOrigin.y) / gridBoxSize)
    -- create the grid box if it does not exist
    if (grid[gridCords.x] == nil) then
        grid[gridCords.x] = {}
        grid[gridCords.x].size = 0
    end
    if (grid[gridCords.x][gridCords.y] == nil) then
        grid[gridCords.x][gridCords.y] = {}
    end
    -- add the object to the grid box
    table.insert(grid[gridCords.x][gridCords.y], object)
    grid[gridCords.x].size = grid[gridCords.x].size + 1
    -- remember which grid box the object is in
    object.gridCords = gridCords
    -- local test = display.newRect((gridCords.x + 0.5) * gridBoxSize, (gridCords.y + 0.5) * gridBoxSize, gridBoxSize,
    --     gridBoxSize)
    -- test:setFillColor(0.9, 0.8, 0.6)
end
local removeFromGrid = function(object)
    -- which grid box is it in
    local gridCords = object.gridCords
    -- remove the object from the grid box
    -- is it in the grid
    if (grid[gridCords.x] and grid[gridCords.x][gridCords.y]) then
        -- remove the object
        for i = #grid[gridCords.x][gridCords.y], 1, -1 do
            if (grid[gridCords.x][gridCords.y][i] == object) then
                table.remove(grid[gridCords.x][gridCords.y], i)
                break
            end
        end
    end
    -- remove empty grid boxes
    if (#grid[gridCords.x][gridCords.y] == 0) then
        grid[gridCords.x][gridCords.y] = nil
        grid[gridCords.x].size = grid[gridCords.x].size - 1
    end
    if (grid[gridCords.x].size == 0) then
        grid[gridCords.x] = nil
    end
end
local updateInGrid = function(object)
    removeFromGrid(object)
    addToGrid(object)
end
local findInGrid = function(returnType, x, y, width, height, object, type)
    -- make easy to use coordinates
    local searchField = {}
    searchField.startX = x - width / 2
    searchField.endX = x + width / 2
    searchField.startY = y - height / 2
    searchField.endY = y + height / 2
    searchField.gridBoxSartX = getGridCoordinate(searchField.startX, 0).x
    searchField.gridBoxEndX = getGridCoordinate(searchField.endX, 0).x
    searchField.gridBoxSartY = getGridCoordinate(0, searchField.startY).y
    searchField.gridBoxEndY = getGridCoordinate(0, searchField.endY).y
    local foundItems = {}
    local found = false
    for row = searchField.gridBoxSartX, searchField.gridBoxEndX do
        for col = searchField.gridBoxSartY, searchField.gridBoxEndY do
            if (grid[row] and grid[row][col]) then
                for i = 1, #grid[row][col] do
                    local thisItem = grid[row][col][i]
                    if (type == nil) then
                        if (object == nil) then
                            print("test")
                            -- return all if nothing specified
                            foundItems[#foundItems + 1] = thisItem
                            found = true
                        elseif (thisItem == object) then
                            -- the single object they are looking for
                            return thisItem
                        end
                    elseif (thisItem.type == type) then
                        if (returnType == "first") then
                            return thisItem
                        elseif (returnType == "all") then
                            foundItems[#foundItems + 1] = thisItem
                            found = true
                        end
                    end
                end
            end
        end
    end
    if (found) then
        return foundItems
    end
end
-- the back ground stuff
local backGroup = display.newGroup()
local background = display.newRect(backGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
background.x = display.contentCenterX
background.y = display.contentCenterY

local home = display.newCircle(backGroup, display.contentCenterX, display.contentCenterY, 20)
home:setFillColor(0.3, 0, 0.1)
addToGrid(home)
-- print("grid")
-- for k, v in pairs(grid) do
--     if (type(v) == "table") then
--         print(k)
--         print("{")
--         for K, V in pairs(v) do
--             print("    " .. K, V)
--         end
--         print("}")
--     else
--         print(k, v)
--     end
-- end
print(getGridCoordinate(home.x, home.y).x, getGridCoordinate(home.x, home.y).y)

local mouse = function(event)
    -- home.x = event.x
    -- home.y = event.y
    if (findInGrid("first", event.x, event.y, 100, 100, home, nil)) then
        home:setFillColor(0.1, 0.4, 0)
        -- print(findInGrid("first", event.x, event.y, 100, 100, home, nil).x)
    else
        home:setFillColor(0.3, 0, 0.1)
    end
    updateInGrid(home)
end
Runtime:addEventListener("mouse", mouse)
