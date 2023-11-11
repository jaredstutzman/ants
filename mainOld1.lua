-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
-- Your code here
local backGroup = display.newGroup()
local backGround = display.newRect(backGroup, display.contentCenterX, display.contentCenterY,
    display.actualContentWidth, display.actualContentHeight)
backGround:setFillColor(1, 1, 1)

local home = display.newCircle(backGroup, display.contentCenterX, display.contentCenterY, 20)
home:setFillColor(0.3, 0, 0.1)

local ants = {}
for i = 1, 10 do
    ants[#ants + 1] = display.newRect(home.x, home.y, 5, 15)
    ants[#ants]:setFillColor(0, 0, 0)
    ants[#ants].target = {
        x = home.x,
        y = home.y
    }
    local headDirection = math.rad(ants[i].rotation)
    local head = {}
    head.x = ants[i].x + ants[i].height / 2 * math.sin(headDirection)
    head.y = ants[i].y - ants[i].height / 2 * math.cos(headDirection)
    ants[#ants].sightFeild = display.newImageRect(backGroup, "pie.png", 30, 30)
    ants[#ants].sightFeild.x = head.x
    ants[#ants].sightFeild.y = head.y
    ants[#ants].sightFeild.rotation = ants[i].rotation
end

local canAntSee = function(ant, obj)
    local headDirection = math.rad(ant.rotation)
    local head = {}
    head.x = ant.x + ant.height / 2 * math.sin(headDirection)
    head.y = ant.y - ant.height / 2 * math.cos(headDirection)
    local distance = math.sqrt((obj.x - head.x) ^ 2 + (obj.y - head.y) ^ 2)
    if (distance < 20) then
        local foodAngle = (math.deg(math.atan2(obj.y - head.y, obj.x - head.x)) + 90) % 360
        local angleDiff = ant.rotation - foodAngle
        if (angleDiff > 180) then
            angleDiff = 360 - angleDiff
        end
        if (math.abs(angleDiff) < 120) then
            return true
        end
    end
end

local wanderAnt = function(ant)
    local headDirection = math.rad(ant.rotation)
    local head = {}
    head.x = ant.x + ant.height / 2 * math.sin(headDirection)
    head.y = ant.y - ant.height / 2 * math.cos(headDirection)
    -- go somewhere in front of the ant
    local randomAngle = math.random(0, 13) ^ 2
    if (math.random(0, 1) == 1) then
        randomAngle = -randomAngle
    end
    local targetAngle = math.rad(ant.rotation + randomAngle)
    ant.target.x = ant.x + 200 / 2 * math.sin(targetAngle)
    ant.target.y = ant.y - 200 / 2 * math.cos(targetAngle)
    ant.target.type = "wander"
    print("wander")
end

local food = {}
for i = 1, 20 do
    local foodX = math.random(0, display.contentWidth)
    local foodY = math.random(0, display.contentHeight)
    food[#food + 1] = display.newCircle(backGroup, foodX, foodY, 5)
    food[#food]:setFillColor(0.8, 0.7, 0.5)
end

local pheromone = {}
local pharomoneLifeTime = 600
local antSpeed = 1
local antTurnSpeed = 4
local arrow = {
    x = 0,
    y = 0
}
local iteration = 0
local update = function()
    iteration = iteration + 1
    if (iteration % 1 == 0) then
        for i = 1, #ants do
            local targetIsFood = false
            if (iteration % 100 == 0) then
                if (ants[i].target.type ~= "wander_back") then
                    wanderAnt(ants[i])
                end
            end
            if (ants[i].target.type == nil) then
                wanderAnt(ants[i])
            end
            ants[i].rotation = ants[i].rotation % 360
            local headDirection = math.rad(ants[i].rotation)
            local head = {}
            head.x = ants[i].x + ants[i].height / 2 * math.sin(headDirection)
            head.y = ants[i].y - ants[i].height / 2 * math.cos(headDirection)
            ants[i].sightFeild.x = head.x
            ants[i].sightFeild.y = head.y
            ants[i].sightFeild.rotation = ants[i].rotation
            -- go twards the food
            if (ants[i].target and ants[i].target.food and ants[i].target.food.carrier == ants[i]) then
                -- folow the pheromone trail back to home
                -- first look for home
                if canAntSee(ants[i], home) then
                    ants[i].target.x = home.x
                    ants[i].target.y = home.y
                    ants[i].target.type = "home"
                    print("home")
                else
                    for p = 1, #pheromone do
                        if canAntSee(ants[i], pheromone[p]) then
                            ants[i].target.x = pheromone[p].x
                            ants[i].target.y = pheromone[p].y
                            ants[i].target.type = "pheromone_home"
                            print("pheromone_home")
                            break
                        end
                    end
                end
            else
                ants[i].target.food = nil
                for f = 1, #food do
                    local foodHomeDistance = math.sqrt((food[f].x - home.x) ^ 2 + (food[f].y - home.y) ^ 2)
                    local isHome = foodHomeDistance <= home.path.radius
                    local distance = math.sqrt((food[f].x - head.x) ^ 2 + (food[f].y - head.y) ^ 2)
                    if (not isHome and not food[f].carrier) then
                        if canAntSee(ants[i], food[f]) then
                            ants[i].target.x = food[f].x
                            ants[i].target.y = food[f].y
                            ants[i].target.food = food[f]
                            ants[i].target.type = "food"
                            print("food")
                            break
                        end
                    end
                end
            end
            -- keep the ant in the bounds
            if (ants[i].target.x < 0) then
                ants[i].target.x = 0
            end
            if (ants[i].target.x > display.contentWidth) then
                ants[i].target.x = display.contentWidth
            end
            if (ants[i].target.y < 0) then
                ants[i].target.y = 0
            end
            if (ants[i].target.y > display.contentHeight) then
                ants[i].target.y = display.contentHeight
            end
            -- move the ant twards the target
            local turnAmount = 0
            local targetAngle =
                (math.deg(math.atan2(ants[i].target.y - ants[i].y, ants[i].target.x - ants[i].x)) + 90) % 360
            turnAmount = math.abs(targetAngle - ants[i].rotation)
            if (targetAngle - ants[i].rotation > 180) then
                turnAmount = ants[i].rotation + 360 - targetAngle
            elseif (targetAngle - ants[i].rotation < -180) then
                turnAmount = targetAngle + 360 - ants[i].rotation
            end
            if (math.abs(targetAngle - ants[i].rotation) > antTurnSpeed and math.abs(targetAngle - ants[i].rotation) <
                360 - antTurnSpeed) then
                if ((targetAngle > ants[i].rotation and targetAngle - ants[i].rotation < 180) or ants[i].rotation -
                    targetAngle > 180) then
                    ants[i].rotation = ants[i].rotation + antTurnSpeed
                else
                    ants[i].rotation = ants[i].rotation - antTurnSpeed
                end
            else
                ants[i].rotation = targetAngle
            end
            headDirection = math.rad(ants[i].rotation)
            head.x = ants[i].x + ants[i].height / 2 * math.sin(headDirection)
            head.y = ants[i].y - ants[i].height / 2 * math.cos(headDirection)
            local distance = math.sqrt((ants[i].target.x - head.x) ^ 2 + (ants[i].target.y - head.y) ^ 2)
            local approachSpeed = distance * 0.04 + 0.1
            local curveSpeed = 180 / turnAmount * 0.1
            -- the min of approachSpeed and curveSpeed
            if (ants[i].target.type == "wander") then
                approachSpeed = approachSpeed * 10
                curveSpeed = curveSpeed * 2
            end
            local currantSpeed = math.min(math.min(approachSpeed, curveSpeed), antSpeed)
            if (distance < 0.1) then
                currantSpeed = 0
            end
            ants[i].x = ants[i].x + currantSpeed * math.sin(headDirection)
            ants[i].y = ants[i].y - currantSpeed * math.cos(headDirection)
            if (distance < 0.1) then
                -- pick up the food
                if (ants[i].target.food and ants[i].target.food.carrier == nil) then
                    ants[i].target.food.carrier = ants[i]
                    -- go in the opposite direction
                    ants[i].target.x = ants[i].x - 200 * math.sin(headDirection)
                    ants[i].target.y = ants[i].y + 200 * math.cos(headDirection)
                    ants[i].target.type = "wander_back"
                    print("wander_back",
                        math.deg(math.atan2(ants[i].target.y - ants[i].y, ants[i].target.x - ants[i].x)))
                end
            end
            -- if target is reached remove it
            distance = math.sqrt((ants[i].target.x - head.x) ^ 2 + (ants[i].target.y - head.y) ^ 2)
            if (distance < 0.1) then
                -- remove the wander back target
                if (ants[i].target.type == "wander_back") then
                    ants[i].target.type = nil
                    print("wander_back removed")
                end
            end
            if (ants[i].target.food and ants[i].target.food.carrier == ants[i]) then
                ants[i].target.food.x = head.x
                ants[i].target.food.y = head.y
            end
            -- drop food
            if (ants[i].target.food and ants[i].target.food.carrier == ants[i]) then
                local foodHomeDistance = math.sqrt((ants[i].target.food.x - home.x) ^ 2 +
                                                       (ants[i].target.food.y - home.y) ^ 2)
                if (foodHomeDistance < home.path.radius) then
                    ants[i].target.food.carrier = nil
                    ants[i].target.food = nil
                    ants[i].target.type = nil
                end
            end
            -- drop trail
            local tail = {}
            tail.x = ants[i].x - ants[i].height / 2 * math.sin(headDirection)
            tail.y = ants[i].y + ants[i].height / 2 * math.cos(headDirection)
            if (iteration % 4 == 0) then
                pheromone[#pheromone + 1] = display.newCircle(backGroup, tail.x, tail.y, ants[i].width * 0.2)
                pheromone[#pheromone]:setFillColor(0.5, 0.6, 1)
                pheromone[#pheromone].createTime = iteration
            end
            -- fade the pheromone trail
            for i = #pheromone, 1, -1 do
                pheromone[i].alpha = 1 - ((iteration - pheromone[i].createTime) / pharomoneLifeTime)
                if (pheromone[i].alpha <= 0) then
                    display.remove(pheromone[i])
                    table.remove(pheromone, i)
                end
            end
        end
    end
end
local mouse = function(event)
    arrow.x = event.x
    arrow.y = event.y
end
Runtime:addEventListener("enterFrame", update)
Runtime:addEventListener("mouse", mouse)
