local gridSystem = require("grid")
local antSystem = require("ants")
-- the back ground stuff
local backGroup = display.newGroup()
local background = display.newRect(backGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
background.x = display.contentCenterX
background.y = display.contentCenterY

local home = display.newCircle(backGroup, display.contentCenterX, display.contentCenterY, 20)
home:setFillColor(0.3, 0, 0.1)
gridSystem.addToGrid(home)

for i = 1, 1 do
    antSystem.createAnt(home, backGroup)
end

local mouse = {
    x = 0,
    y = 0
}
local tickCount = 0
local update = function()
    -- if the ant has food target
    -- if it sees home the target should be home
    -- else the target should be pheromone trail home
    -- else if the ant sees food the target should be food
    -- else the target should be a random direction
    ----------
    tickCount = tickCount + 1
    for i = 1, #antSystem.ants do
        local newTarget = antSystem.randomTarget(antSystem.ants[i])
        if (tickCount % 120 == 0) then
            antSystem.ants[i].target.type = "rotation"
            antSystem.ants[i].target.rotation = newTarget
        end
        if (antSystem.ants[i].carrying) then
            if (antSystem.canSee(antSystem.ants[i], home)) then

            end
        end
        -- ants seek the target
        antSystem.moveTowardTarget(antSystem.ants[i])
    end
end

local mouse = function(event)
    mouse = event
    gridSystem.updateInGrid(home)
    antSystem.ants[1].target.x = event.x
    antSystem.ants[1].target.y = event.y
    antSystem.ants[1].target.type = "location"
    -- ants[1].target.rotation = math.deg(math.atan2(event.y - ants[1].y, event.x - ants[1].x)) + 90
    -- ants[1].target.type = "direction"
    print(antSystem.canSee(antSystem.ants[1], home))
end
Runtime:addEventListener("mouse", mouse)
Runtime:addEventListener("enterFrame", update)
