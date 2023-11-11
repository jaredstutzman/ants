-- the grid system
local rtn = {}
rtn.grid = {}
local gridBoxSize = 20
rtn.gridLocalOrigin = {
    x = 0,
    y = 0
}
rtn.getGridCoordinate = function(x, y)
    local gridCords = {}
    gridCords.x = math.floor((x - rtn.gridLocalOrigin.x) / gridBoxSize)
    gridCords.y = math.floor((y - rtn.gridLocalOrigin.y) / gridBoxSize)
    return gridCords
end
rtn.addToGrid = function(object)
    -- witch grid box would it fall into
    local gridCords = rtn.getGridCoordinate(object.x, object.y)
    -- create the grid box if it does not exist
    if (rtn.grid[gridCords.x] == nil) then
        rtn.grid[gridCords.x] = {}
        rtn.grid[gridCords.x].size = 0
    end
    if (rtn.grid[gridCords.x][gridCords.y] == nil) then
        rtn.grid[gridCords.x][gridCords.y] = {}
    end
    -- add the object to the grid box
    table.insert(rtn.grid[gridCords.x][gridCords.y], object)
    rtn.grid[gridCords.x].size = rtn.grid[gridCords.x].size + 1
    -- remember which grid box the object is in
    object.gridCords = gridCords
end
rtn.removeFromGrid = function(object)
    -- which grid box is it in
    local gridCords = object.gridCords
    -- remove the object from the grid box
    -- is it in the grid
    if (rtn.grid[gridCords.x] and rtn.grid[gridCords.x][gridCords.y]) then
        -- remove the object
        for i = #rtn.grid[gridCords.x][gridCords.y], 1, -1 do
            if (rtn.grid[gridCords.x][gridCords.y][i] == object) then
                table.remove(rtn.grid[gridCords.x][gridCords.y], i)
                break
            end
        end
    end
    -- remove empty grid boxes
    if (#rtn.grid[gridCords.x][gridCords.y] == 0) then
        rtn.grid[gridCords.x][gridCords.y] = nil
        rtn.grid[gridCords.x].size = rtn.grid[gridCords.x].size - 1
    end
    if (rtn.grid[gridCords.x].size == 0) then
        rtn.grid[gridCords.x] = nil
    end
end
rtn.updateInGrid = function(object)
    rtn.removeFromGrid(object)
    rtn.addToGrid(object)
end
rtn.findInGrid = function(returnType, x, y, width, height, object, type)
    -- make easy to use coordinates
    local searchField = {}
    searchField.startX = x - width / 2
    searchField.endX = x + width / 2
    searchField.startY = y - height / 2
    searchField.endY = y + height / 2
    searchField.gridBoxSartX = rtn.getGridCoordinate(searchField.startX, 0).x
    searchField.gridBoxEndX = rtn.getGridCoordinate(searchField.endX, 0).x
    searchField.gridBoxSartY = rtn.getGridCoordinate(0, searchField.startY).y
    searchField.gridBoxEndY = rtn.getGridCoordinate(0, searchField.endY).y
    local foundItems = {}
    local found = false
    for row = searchField.gridBoxSartX, searchField.gridBoxEndX do
        for col = searchField.gridBoxSartY, searchField.gridBoxEndY do
            if (rtn.grid[row] and rtn.grid[row][col]) then
                for i = 1, #rtn.grid[row][col] do
                    local thisItem = rtn.grid[row][col][i]
                    if (type == nil) then
                        if (object == nil) then
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
return rtn
