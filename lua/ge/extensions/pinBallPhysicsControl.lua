
local M = {}

local PinBallEnabled = false
local multiplier = 1

local function updateVehicles()
    if PinBallEnabled then
        be:queueAllObjectLua('if PinBall then PinBall.setEnabled(true) end')
    else
        be:queueAllObjectLua('if PinBall then PinBall.setEnabled(false) end')
    end
    be:queueAllObjectLua('if PinBall then PinBall.setforceMultiplier('..multiplier..') end')
end

local function enablePinBallPhysics(bolean)
    if type(bolean) == "string" then -- server event arrives as string
        if bolean == "true" then
            PinBallEnabled = true
        else
            PinBallEnabled = false
        end
    elseif not bolean then
        PinBallEnabled = false
    else
        PinBallEnabled = true
    end
    updateVehicles()
end

local function disablePinBallPhysics(bolean)
    if type(bolean) == "string" then -- server event arrives as string
        if bolean == "true" then
            PinBallEnabled = false
        else
            PinBallEnabled = true
        end
    elseif not bolean then
        PinBallEnabled = true
    else
        PinBallEnabled = false
    end
    updateVehicles()
end

local function PinBallPhysics_multiplier(number)
    if type(number) == "string" then -- server event arrives as string
        number = tonumber(number)
        if type(number) ~= "number" then
            return
        end
    end
    multiplier = number
    updateVehicles()
end

local function onVehicleSpawned(vehicleID)
    updateVehicles()
end

--extensions.reload("pinBallPhysicsControl") -- copy this into the console to reload just the file instead of reloading the entire lua

if MPGameNetwork then AddEventHandler("PinBallPhysics_enable", enablePinBallPhysics) end
if MPGameNetwork then AddEventHandler("PinBallPhysics_disable", disablePinBallPhysics) end
if MPGameNetwork then AddEventHandler("PinBallPhysics_multiplier", PinBallPhysics_multiplier) end

M.enablePinBallPhysics = enablePinBallPhysics
M.disablePinBallPhysics = disablePinBallPhysics
M.PinBallPhysics_multiplier = PinBallPhysics_multiplier

M.onVehicleSpawned = onVehicleSpawned
M.onInit = function() setExtensionUnloadMode(M, "manual") end

return M