local rtn = {}
-- create the ants
local antMaxSpeed = 1
local antFOV = 120
local antSightRange = 15
local antMaxTurnSpeed = 5
local ants = {}
rtn.ants = ants
rtn.createAnt = function(home, backGroup)
    ants[#ants + 1] = display.newRect(home.x, home.y, 5, 15)
    ants[#ants]:setFillColor(0, 0, 0)
    ants[#ants].target = {
        x = home.x,
        y = home.y
    }
    local headDirection = math.rad(ants[#ants].rotation)
    local head = {}
    head.x = ants[#ants].x + ants[#ants].height / 2 * math.sin(headDirection)
    head.y = ants[#ants].y - ants[#ants].height / 2 * math.cos(headDirection)
    ants[#ants].sightFeild = display.newImageRect(backGroup, "pie.png", 30, 30)
    ants[#ants].sightFeild.x = head.x
    ants[#ants].sightFeild.y = head.y
    ants[#ants].sightFeild.rotation = ants[#ants].rotation
    return ants[#ants]
end
rtn.moveTowardTarget = function()
    -- move the ant in a target direction
    -- if the direction is unknown find it using the target coordinates
    -- slow down when turning sharp or when approaching the target location
    for i = 1, #ants do
        if (ants[i].target.type ~= nil) then
            local currentSpeed = antMaxSpeed
            if (ants[i].target.type == "location") then
                ants[i].target.rotation = (math.deg(math.atan2(ants[i].target.y - ants[i].y,
                    ants[i].target.x - ants[i].x)) + 90)
                local head = {}
                head.x = ants[i].x + ants[i].height / 2 * math.sin(math.rad(ants[i].rotation))
                head.y = ants[i].y - ants[i].height / 2 * math.cos(math.rad(ants[i].rotation))
                local targetDistance = math.sqrt((head.x - ants[1].target.x) ^ 2 + (head.y - ants[1].target.y) ^ 2)
                -- set ant speed
                currentSpeed = math.min(antMaxSpeed, targetDistance / 10)
            end
            -- set the ants rotation
            local turnAmount = 0
            local targetAngle = ants[i].target.rotation % 360
            turnAmount = math.abs(targetAngle - ants[i].rotation)
            if (targetAngle - ants[i].rotation > 180) then
                turnAmount = ants[i].rotation + 360 - targetAngle
            elseif (targetAngle - ants[i].rotation < -180) then
                turnAmount = targetAngle + 360 - ants[i].rotation
            end
            if (math.abs(targetAngle - ants[i].rotation) > antMaxTurnSpeed and math.abs(targetAngle - ants[i].rotation) <
                360 - antMaxTurnSpeed) then
                if ((targetAngle > ants[i].rotation and targetAngle - ants[i].rotation < 180) or ants[i].rotation -
                    targetAngle > 180) then
                    ants[i].rotation = ants[i].rotation + antMaxTurnSpeed
                else
                    ants[i].rotation = ants[i].rotation - antMaxTurnSpeed
                end
            else
                ants[i].rotation = targetAngle
            end
            -- reset the speed
            currentSpeed = math.min(180 / (turnAmount + 1) / 10, currentSpeed)
            -- move the ant
            ants[i].x = ants[i].x + math.sin(math.rad(ants[i].rotation)) * currentSpeed
            ants[i].y = ants[i].y - math.cos(math.rad(ants[i].rotation)) * currentSpeed
            -- show the FOV
            local head = {}
            head.x = ants[i].x + ants[i].height / 2 * math.sin(math.rad(ants[i].rotation))
            head.y = ants[i].y - ants[i].height / 2 * math.cos(math.rad(ants[i].rotation))
            ants[i].sightFeild.x = head.x
            ants[i].sightFeild.y = head.y
            ants[i].sightFeild.rotation = ants[i].rotation
        end
    end
end
return rtn
