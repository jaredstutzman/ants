local gridSystem = require("grid")
local rtn = {}
-- create the ants
local antMaxSpeed = 1
local antFOV = 120
local antSightRange = 15
local antMaxTurnSpeed = 5
local ants = {}
rtn.ants = ants
local pheromone = {}
rtn.pheromone = pheromone
rtn.createAnt = function(home)
    ants[#ants + 1] = display.newRect(home.x, home.y, 5, 15)
    ants[#ants]:setFillColor(0, 0, 0)
    ants[#ants].type = "ant"
    ants[#ants].carrying = nil
    ants[#ants].currentSpeedVariant = 1
    ants[#ants].lastImportantDecisionTime = 1
    ants[#ants].target = {
        x = home.x,
        y = home.y
    }
    local headDirection = math.rad(ants[#ants].rotation)
    local head = {}
    head.x = ants[#ants].x + ants[#ants].height / 2 * math.sin(headDirection)
    head.y = ants[#ants].y - ants[#ants].height / 2 * math.cos(headDirection)
    ants[#ants].sightFeild = display.newImageRect(_G.backGroup, "pie.png", 30, 30)
    ants[#ants].sightFeild.x = head.x
    ants[#ants].sightFeild.y = head.y
    ants[#ants].sightFeild.rotation = ants[#ants].rotation
    return ants[#ants]
end
rtn.dropPheromone = function(object, type, createTime)
    local tail = {}
    tail.x = object.x - object.height / 2 * math.sin(math.rad(object.rotation))
    tail.y = object.y + object.height / 2 * math.cos(math.rad(object.rotation))
    pheromone[#pheromone + 1] = display.newCircle(_G.backGroup, tail.x, tail.y, object.width * 0.2)
    pheromone[#pheromone]:setFillColor(0.5, 0.6, 1)
    if (type == "pheromone_finding_home") then
        pheromone[#pheromone]:setFillColor(0.8, 0.4, 0.3)
    end
    pheromone[#pheromone].createTime = createTime
    pheromone[#pheromone].type = type
    gridSystem.addToGrid(pheromone[#pheromone])
end
rtn.randomTarget = function(object)
    local randomAngleDif = math.ceil(math.random(0, 180) ^ 3 / 32400)
    local polarity = math.random(1, 2) * 2 - 3
    local angle = object.rotation + randomAngleDif * polarity
    return angle
end
rtn.moveTowardTarget = function(object)
    -- move the ant in a target direction
    -- if the direction is unknown find it using the target coordinates
    -- slow down when turning sharp or when approaching the target location
    if (object.target.type ~= nil) then
        local currentSpeed = antMaxSpeed
        if (object.target.type == "location") then
            object.target.rotation = (math.deg(math.atan2(object.target.y - object.y, object.target.x - object.x)) + 90)
            local head = {}
            head.x = object.x + object.height / 2 * math.sin(math.rad(object.rotation))
            head.y = object.y - object.height / 2 * math.cos(math.rad(object.rotation))
            local targetDistance = math.getDistance(head, ants[1].target)
            -- set ant speed
            currentSpeed = math.min(antMaxSpeed, targetDistance / 10)
        end
        -- set the ants rotation
        local turnAmount = 0
        local targetAngle = object.target.rotation % 360
        turnAmount = math.abs(targetAngle - object.rotation)
        if (targetAngle - object.rotation > 180) then
            turnAmount = object.rotation + 360 - targetAngle
        elseif (targetAngle - object.rotation < -180) then
            turnAmount = targetAngle + 360 - object.rotation
        end
        if (math.abs(targetAngle - object.rotation) > antMaxTurnSpeed and math.abs(targetAngle - object.rotation) < 360 -
            antMaxTurnSpeed) then
            if ((targetAngle > object.rotation and targetAngle - object.rotation < 180) or object.rotation - targetAngle >
                180) then
                object.rotation = object.rotation + antMaxTurnSpeed
            else
                object.rotation = object.rotation - antMaxTurnSpeed
            end
        else
            object.rotation = targetAngle
        end
        -- reset the speed
        currentSpeed = math.min(180 / (turnAmount + 1) / 10, currentSpeed)
        -- currently going extra fast or slow
        local randomSpeed = math.random(0, 120)
        if (randomSpeed == math.random(0, 120)) then
            object.currentSpeedVariant = randomSpeed / 120 + 0.5
        end
        currentSpeed = currentSpeed * object.currentSpeedVariant
        -- move the ant
        object.x = object.x + math.sin(math.rad(object.rotation)) * currentSpeed
        object.y = object.y - math.cos(math.rad(object.rotation)) * currentSpeed
        -- show the FOV
        local head = {}
        head.x = object.x + object.height / 2 * math.sin(math.rad(object.rotation))
        head.y = object.y - object.height / 2 * math.cos(math.rad(object.rotation))
        object.sightFeild.x = head.x
        object.sightFeild.y = head.y
        object.sightFeild.rotation = object.rotation
    end
end
rtn.canSee = function(object, targetObj, type, returnAll)
    local objectSeen = gridSystem.findInGrid("all", object.x, object.y, antSightRange * 2, antSightRange * 2, targetObj,
        type)
    if (objectSeen) then
        local allObject = {}
        for i = 1, #objectSeen do
            local head = {}
            head.x = object.x + object.height / 2 * math.sin(math.rad(object.rotation))
            head.y = object.y - object.height / 2 * math.cos(math.rad(object.rotation))
            local distance = math.getDistance(head, objectSeen[i])
            if (objectSeen[i].path.radius) then
                distance = distance - objectSeen[i].path.radius
            end
            if (distance <= antSightRange) then
                local targetAngle = (math.deg(math.atan2(objectSeen[i].y - object.y, objectSeen[i].x - object.x)) + 90)
                local angleDif = math.abs(targetAngle - object.rotation)
                if (angleDif > 180) then
                    angleDif = 360 - angleDif
                end
                if (angleDif < antFOV / 2) then
                    if (returnAll) then
                        allObject[#allObject + 1] = objectSeen[i]
                    else
                        return objectSeen[i]
                    end
                end
            end
        end
        if (returnAll) then
            return allObject
        end
    end
end
return rtn
