-- === CONFIG ===
local config = require("/services/gateDriver/config_gateDriver")
local core_config = require("/config/config")

local HOST_ID = core_config.HOST_ID
local PULSE_TIME = config.PULSE_TIME or 0.5
local PROTOCOL = config.PROTOCOL or "control"

-- === STATE ===
local currentAction = "deactivate"

-- === STATUS ===
local function getStatus(action)
    if redstone.getInput("right") and action == "activate" then
        return "active"

    elseif redstone.getInput("left") and action == "deactivate" then
        return "inactive"

    elseif not redstone.getInput("right")
       and not redstone.getInput("left")
       and (action == "activate" or action == "deactivate") then
        return "moving"

    else
        return "error"
    end
end

-- === ACTIONS ===
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

-- === MESSAGE HANDLER ===
local function handle(msg, sender, protocol)
    if protocol ~= PROTOCOL then return false end
    if msg.id ~= HOST_ID then return end

    if msg.action == "activate" then
        currentAction = "activate"
        activate()

    elseif msg.action == "deactivate" then
        currentAction = "deactivate"
        deactivate()

    elseif msg.action == "pulse" then
        pulse()

    elseif msg.action == "status" then
        -- nur Antwort
    end

    return {
        id = HOST_ID,
        status = getStatus(currentAction)
    }
        
end

local function run()
    while true do
        sleep(1)
    end
end

-- === EXPORT ===
return {
    protocol = PROTOCOL,   -- frei wählbar (z. B. "system")
    run = run,
    handle = handle
}
