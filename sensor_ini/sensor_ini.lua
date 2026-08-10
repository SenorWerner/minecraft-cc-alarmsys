local config = require("config_sensor_ini")

local HOST_ID = config.HOST_ID
local PULSE_TIME = config.PULSE_TIME

local currentAction = "deactivate"

local function getStatus(action)
    if redstone.getInput("right") and action == "activate" then
        return "active"
    elseif redstone.getInput("left") and action == "deactivate" then
        return "inactive"
    elseif not redstone.getInput("right") and not redstone.getInput("left") then
        return "moving"
    else
        return "error"
    end
end

local function activate()
    redstone.setOutput("back", true)
end

local function deactivate()
    redstone.setOutput("back", false)
end

local function pulse()
    redstone.setOutput("left", true)
    sleep(PULSE_TIME)
    redstone.setOutput("left", false)
end

-- WIRD VOM DISPATCHER AUFGERUFEN
local function handle(sender, msg, protocol)
    if type(msg) ~= "table" then return end
    if msg.id ~= HOST_ID then return end

    if msg.action == "activate" then
        currentAction = "activate"
        activate()

    elseif msg.action == "deactivate" then
        currentAction = "deactivate"
        deactivate()

    elseif msg.action == "pulse" then
        pulse()
    end

    rednet.send(sender, {
        id = HOST_ID,
        status = getStatus(currentAction)
    }, "control")

    print(getStatus(currentAction), currentAction)
end

return {
    protocol = "control",
    handle = handle
}
