local gridSystem = require("grid")
-- the back ground stuff
local backGroup = display.newGroup()
local background = display.newRect(backGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
background.x = display.contentCenterX
background.y = display.contentCenterY

local home = display.newCircle(backGroup, display.contentCenterX, display.contentCenterY, 20)
home:setFillColor(0.3, 0, 0.1)
gridSystem.addToGrid(home)

local mouse = {
    x = 0,
    y = 0
}
local update = function()
end

local mouse = function(event)
    mouse = event
    gridSystem.updateInGrid(home)
end
Runtime:addEventListener("mouse", mouse)
Runtime:addEventListener("enterFrame", update)
