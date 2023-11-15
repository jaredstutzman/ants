if (type(math.getDistance) == "function") then
    error("attempt to redefine math.getDistance in main.lua")
end
math.getDistance = function(obj1, obj2)
    return math.sqrt((obj1.x - obj2.x) ^ 2 + (obj1.y - obj2.y) ^ 2)
end

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

local food = {}
for i = 1, 20 do
    local foodX = math.random(0, display.contentWidth)
    local foodY = math.random(0, display.contentHeight)
    food[#food + 1] = display.newCircle(backGroup, foodX, foodY, 5)
    food[#food]:setFillColor(0.8, 0.7, 0.5)
    food[#food].type = "food"
    gridSystem.addToGrid(food[#food])
end

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
    -- else if the ant sees food that does not have a carrier the target should be food
    -- else the target should be a random direction
    ----------
    tickCount = tickCount + 1
    for i = 1, #antSystem.ants do
        -- if nothing else do random
        if (tickCount % 120 == 0) then
            local newTarget = antSystem.randomTarget(antSystem.ants[i])
            antSystem.ants[i].target.type = "rotation"
            antSystem.ants[i].target.rotation = newTarget
            antSystem.ants[i].target.object = nil
        end
        -- does the ant have food
        if (antSystem.ants[i].carrying) then
            -- posibly go home
            if (antSystem.canSee(antSystem.ants[i], home)) then
                antSystem.ants[i].target.type = "location"
                antSystem.ants[i].target.object = home
                antSystem.ants[i].target.x = home.x
                antSystem.ants[i].target.y = home.y
            else
                -- else follow the trail home
                if (antSystem.canSee(antSystem.ants[i], nil, "pheromone_finding_food")) then
                end
            end
        else
            -- pick up food it is not picked up or at home already
            local food = antSystem.canSee(antSystem.ants[i], nil, "food")
            if (food and food.carrier == nil) then
                local distance = math.getDistance(home, food)
                if (distance >= home.path.radius) then
                    antSystem.ants[i].target.type = "location"
                    antSystem.ants[i].target.object = food
                    antSystem.ants[i].target.x = food.x
                    antSystem.ants[i].target.y = food.y
                end
            end
        end
        -- ants seek the target
        antSystem.moveTowardTarget(antSystem.ants[i])
        -- pick up food if close enough
        if (antSystem.ants[i].target and antSystem.ants[i].target.object and antSystem.ants[i].target.object.carrier ==
            nil) then
            local head = {}
            head.x = antSystem.ants[i].x + antSystem.ants[i].height / 2 * math.sin(math.rad(antSystem.ants[i].rotation))
            head.y = antSystem.ants[i].y - antSystem.ants[i].height / 2 * math.cos(math.rad(antSystem.ants[i].rotation))
            local distance = math.getDistance(head, antSystem.ants[i].target.object)
            if (distance < 0.1) then
                antSystem.ants[i].carrying = antSystem.ants[i].target.object
                antSystem.ants[i].carrying.carrier = antSystem.ants[i]
            end
        end
        -- picked up food should move with ant
        if (antSystem.ants[i].carrying) then
            local head = {}
            head.x = antSystem.ants[i].x + antSystem.ants[i].height / 2 * math.sin(math.rad(antSystem.ants[i].rotation))
            head.y = antSystem.ants[i].y - antSystem.ants[i].height / 2 * math.cos(math.rad(antSystem.ants[i].rotation))
            antSystem.ants[i].carrying.x = head.x
            antSystem.ants[i].carrying.y = head.y
        end
        -- if ant is home drop food
        if (antSystem.ants[i].carrying) then
            local head = {}
            head.x = antSystem.ants[i].x + antSystem.ants[i].height / 2 * math.sin(math.rad(antSystem.ants[i].rotation))
            head.y = antSystem.ants[i].y - antSystem.ants[i].height / 2 * math.cos(math.rad(antSystem.ants[i].rotation))
            local distance = math.getDistance(home, head)
            if (distance <= home.path.radius) then
                antSystem.ants[i].carrying.carrier = nil
                antSystem.ants[i].carrying = nil
            end
        end
        -- drop pheromone
        if (tickCount % 4 == 0) then
            if (antSystem.ants[i].carrying) then
                antSystem.dropPheromone(antSystem.ants[i], "pheromone_finding_home", tickCount, backGroup)
            else
                antSystem.dropPheromone(antSystem.ants[i], "pheromone_finding_food", tickCount, backGroup)
            end
        end
    end
end

local mouse = function(event)
    mouse = event
    gridSystem.updateInGrid(home)
    antSystem.ants[1].target.x = event.x
    antSystem.ants[1].target.y = event.y
    antSystem.ants[1].target.object = nil
    antSystem.ants[1].target.type = "location"
    -- ants[1].target.rotation = math.deg(math.atan2(event.y - ants[1].y, event.x - ants[1].x)) + 90
    -- ants[1].target.type = "direction"
end
Runtime:addEventListener("mouse", mouse)
Runtime:addEventListener("enterFrame", update)
