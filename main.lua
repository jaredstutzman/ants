if (type(math.getDistance) == "function") then
    error("attempt to redefine math.getDistance in main.lua")
end
math.getDistance = function(obj1, obj2)
    return math.sqrt((obj1.x - obj2.x) ^ 2 + (obj1.y - obj2.y) ^ 2)
end

local gridSystem = require("grid")
local antSystem = require("ants")
-- the back ground stuff
_G.backGroup = display.newGroup()
local background = display.newRect(_G.backGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
background.x = display.contentCenterX
background.y = display.contentCenterY

local home = display.newCircle(_G.backGroup, display.contentCenterX, display.contentCenterY, 20)
home:setFillColor(0.3, 0, 0.1)
home.type = "home"
gridSystem.addToGrid(home)

local food = {}
for i = 1, 3 do
    local pileLocation = {}
    pileLocation.x = math.random(0, display.contentWidth)
    pileLocation.y = math.random(0, display.contentHeight)
    for pile = 1, 15 do
        local randomDistance = math.random(1, 40)
        local randomAngle = math.random(1, 360)
        local foodX = pileLocation.x + randomDistance * math.sin(math.rad(randomAngle))
        local foodY = pileLocation.y + randomDistance * math.cos(math.rad(randomAngle))
        food[#food + 1] = display.newCircle(_G.backGroup, foodX, foodY, 5)
        food[#food]:setFillColor(0.8, 0.7, 0.5)
        food[#food].type = "food"
        gridSystem.addToGrid(food[#food])
    end
end

for i = 1, 10 do
    antSystem.createAnt(home)
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
    -- else if the ant can see it the target should be pheromone trail to the food
    -- else the target should be a random direction
    ----------
    tickCount = tickCount + 1
    for i = 1, #antSystem.ants do
        -- if nothing else do random
        if (tickCount % 30 == 0) then
            local shouldWander = false
            local waitedOnImportant = tickCount > antSystem.ants[i].lastImportantDecisionTime + 100
            if (antSystem.ants[i].target.object) then
                local followingHomePheromone = antSystem.ants[i].target.object.type == "pheromone_finding_home"
                local followingFoodPheromone = antSystem.ants[i].target.object.type == "pheromone_finding_food"
                local followingPheromone = followingHomePheromone or followingFoodPheromone
                local goingHome = antSystem.ants[i].target.object.type == "home"
                local findingFood = antSystem.ants[i].target.object.type == "food"
                if (waitedOnImportant or followingPheromone or goingHome or findingFood) then
                    shouldWander = true
                end
            end
            if (waitedOnImportant or shouldWander) then
                local newTarget = antSystem.randomTarget(antSystem.ants[i])
                antSystem.ants[i].target.type = "rotation"
                antSystem.ants[i].target.rotation = newTarget
                antSystem.ants[i].target.object = nil
            end
        end
        -- does the ant have food
        if (antSystem.ants[i].carrying) then
            -- posibly go home
            if (antSystem.canSee(antSystem.ants[i], home)) then
                antSystem.ants[i].target.type = "location"
                antSystem.ants[i].target.object = home
                antSystem.ants[i].target.x = home.x
                antSystem.ants[i].target.y = home.y
                antSystem.ants[i].lastImportantDecisionTime = tickCount
            else
                -- else follow the trail home
                -- but first start to turn around
                local pheromone = antSystem.canSee(antSystem.ants[i], nil, "pheromone_finding_food", true)
                if (antSystem.ants[i].justPickUpFood) then
                    antSystem.ants[i].justPickUpFood = nil
                    antSystem.ants[i].target.type = "rotation"
                    antSystem.ants[i].target.object = nil
                    antSystem.ants[i].target.rotation = antSystem.ants[i].rotation + 180
                    antSystem.ants[i].lastImportantDecisionTime = tickCount
                elseif (pheromone and #pheromone > 0) then
                    local head = antSystem.getHead(antSystem.ants[i])
                    -- local farthest = pheromone[1]
                    -- local farthestDistance = math.getDistance(farthest, head)
                    -- local leftPheromone = {}
                    -- local rightPheromone = {}
                    -- for f = 1, #pheromone do
                    --     if (pheromone[f].type == "pheromone_finding_food") then
                    --         local distance = math.getDistance(pheromone[f], head)
                    --         if (distance < farthestDistance) then
                    --             farthest = pheromone[f]
                    --             farthestDistance = distance
                    --         end
                    --         -- is the pheromone on the right or the left
                    --         local pheromoneAngle = (math.deg(
                    --             math.atan2(pheromone[f].y - antSystem.ants[i].y, pheromone[f].x - antSystem.ants[i].x)) +
                    --                                    90) % 360
                    --         -- p90, a0 is to the right and 
                    --         local isToTheRight = math.abs(pheromoneAngle - antSystem.ants[i].rotation % 360 + 90) > 90
                    --         if (isToTheRight) then
                    --             rightPheromone[#rightPheromone + 1] = pheromone[f]
                    --         else
                    --             leftPheromone[#leftPheromone + 1] = pheromone[f]
                    --         end
                    --     end
                    -- end
                    -- -- choose a direction to follow
                    -- local targetSide = rightPheromone
                    -- if (#leftPheromone > #rightPheromone) then
                    --     targetSide = leftPheromone
                    -- end
                    -- -- travel in the average direction of the pheromone group
                    -- local thisAngle = (math.deg(math.atan2(pheromone[1].y - antSystem.ants[i].y,
                    --     pheromone[1].x - antSystem.ants[i].x)) + 90)
                    -- local averageAngle = thisAngle
                    -- for f = 2, #pheromone do
                    --     thisAngle = (math.deg(math.atan2(pheromone[f].y - antSystem.ants[i].y,
                    --         pheromone[f].x - antSystem.ants[i].x)) + 90)
                    --     local relitave = (thisAngle + 180 - ((averageAngle + 180) % 360 - 180)) % 360 - 180
                    --     local thisAverage = relitave / f
                    --     averageAngle = (averageAngle + thisAverage) % 360
                    -- end
                    -- local targetDirection = (math.deg(math.atan2(farthest.y - antSystem.ants[i].y,
                    --     farthest.x - antSystem.ants[i].x)) + 90)
                    local oldest = pheromone[1]
                    for f = 2, #pheromone do
                        if (pheromone[f].createTime < oldest.createTime) then
                            oldest = pheromone[f]
                        end
                    end
                    local targetDirection = (math.deg(math.atan2(oldest.y - antSystem.ants[i].y,
                        oldest.x - antSystem.ants[i].x)) + 90)
                    antSystem.ants[i].target.type = "rotation"
                    antSystem.ants[i].target.object = oldest
                    antSystem.ants[i].target.rotation = targetDirection
                    antSystem.ants[i].lastImportantDecisionTime = tickCount
                end
            end
        else
            -- look for food to carrie
            local food = antSystem.canSee(antSystem.ants[i], nil, "food")
            local canSeeFood = false
            if (food and food.carrier == nil) then
                local distance = math.getDistance(home, food)
                if (distance >= home.path.radius) then
                    canSeeFood = true
                end
            end
            -- look for pheromone to fallow to the food
            local pheromone = antSystem.canSee(antSystem.ants[i], nil, "pheromone_finding_home", true)
            local canSeePheromone = false
            local targetDirection
            local oldest
            if (pheromone and #pheromone > 0) then
                canSeePheromone = true
                oldest = pheromone[1]
                for f = 2, #pheromone do
                    if (pheromone[f].createTime < oldest.createTime) then
                        oldest = pheromone[f]
                    end
                end
                targetDirection =
                    (math.deg(math.atan2(oldest.y - antSystem.ants[i].y, oldest.x - antSystem.ants[i].x)) + 90)
            end
            -- pick up food it is not picked up or at home already
            if (canSeeFood) then
                antSystem.ants[i].target.type = "location"
                antSystem.ants[i].target.object = food
                antSystem.ants[i].target.x = food.x
                antSystem.ants[i].target.y = food.y
                antSystem.ants[i].lastImportantDecisionTime = tickCount
            elseif (canSeePheromone) then
                antSystem.ants[i].target.type = "rotation"
                antSystem.ants[i].target.object = oldest
                antSystem.ants[i].target.rotation = targetDirection
                antSystem.ants[i].lastImportantDecisionTime = tickCount
            end
        end
        -- keep ants in bounds
        if (math.abs(antSystem.ants[i].x - display.contentCenterX) > display.actualContentWidth / 2) then
            if (antSystem.ants[i].x - display.contentCenterX > display.actualContentWidth / 2) then
                antSystem.ants[i].x = display.contentCenterX + display.actualContentWidth / 2
            else
                antSystem.ants[i].x = display.contentCenterX - display.actualContentWidth / 2
            end
        end
        if (math.abs(antSystem.ants[i].y - display.contentCenterY) > display.actualContentHeight / 2) then
            if (antSystem.ants[i].y - display.contentCenterY > display.actualContentHeight / 2) then
                antSystem.ants[i].y = display.contentCenterY + display.actualContentHeight / 2
            else
                antSystem.ants[i].y = display.contentCenterY - display.actualContentHeight / 2
            end
        end
        -- ants seek the target
        antSystem.moveTowardTarget(antSystem.ants[i])
        -- pick up food if close enough
        if (antSystem.ants[i].target and antSystem.ants[i].target.object and antSystem.ants[i].target.object.type ==
            "food" and antSystem.ants[i].target.object.carrier == nil) then
            local head = antSystem.getHead(antSystem.ants[i])
            local distance = math.getDistance(head, antSystem.ants[i].target.object)
            if (distance < 0.1) then
                antSystem.ants[i].carrying = antSystem.ants[i].target.object
                antSystem.ants[i].carrying.carrier = antSystem.ants[i]
                antSystem.ants[i].justPickUpFood = true
            end
        end
        -- picked up food should move with ant
        if (antSystem.ants[i].carrying) then
            local head = antSystem.getHead(antSystem.ants[i])
            antSystem.ants[i].carrying.x = head.x
            antSystem.ants[i].carrying.y = head.y
            gridSystem.updateInGrid(antSystem.ants[i].carrying)
        end
        -- if ant is home drop food
        if (antSystem.ants[i].carrying) then
            local head = antSystem.getHead(antSystem.ants[i])
            local distance = math.getDistance(home, head)
            if (distance <= home.path.radius) then
                antSystem.ants[i].carrying.carrier = nil
                antSystem.ants[i].carrying = nil
            end
        end
        -- drop pheromone
        if (tickCount % 4 == 0) then
            if (antSystem.ants[i].carrying) then
                antSystem.dropPheromone(antSystem.ants[i], "pheromone_finding_home", tickCount)
            else
                antSystem.dropPheromone(antSystem.ants[i], "pheromone_finding_food", tickCount)
            end
        end
        -- fade and spread pheromone
        if (#antSystem.pheromone > 0) then
            for n = math.ceil(#antSystem.pheromone / 20), 1, -1 do
                -- fade the particle
                local index = math.random(1, #antSystem.pheromone)
                local pheromone = antSystem.pheromone[index]
                pheromone.alpha = pheromone.alpha - 0.003
                -- nudge particle in some direction
                pheromone.x = pheromone.x + math.random(1, 3) * 0.1 - 0.2
                pheromone.y = pheromone.y + math.random(1, 3) * 0.1 - 0.2
                -- eventually delete it
                if (pheromone.alpha <= 0) then
                    gridSystem.removeFromGrid(pheromone)
                    table.remove(antSystem.pheromone, index)
                    display.remove(pheromone)
                end
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
