-- === CONFIG ===
local config = require("/services/gateDriver/config_gateDriver")
local CORE_CONFIG_PATH = config.CORE_CONFIG_PATH
local core_config = require(CORE_CONFIG_PATH)

local HOSTNAME = core_config.HOSTNAME
local PROTOCOL = config.PROTOCOL or "control"

--Feedback config
  
local FEEDBACK_ACTIVE_ON = config.FEEDBACK_ACTIVE_ON
local FEEDBACK_INACTIVE_ON = config.FEEDBACK_INACTIVE_ON
local FEEDBACK_SIDE_ACTIVE = config.FEEDBACK_SIDE_ACTIVE
local FEEDBACK_SIDE_INACTIVE = config.FEEDBACK_SIDE_INACTIVE

--Status Strings
  
local FEEDBACK_RETURN_STRING_ACTIVE = config.FEEDBACK_RETURN_STRING_ACTIVE
local FEEDBACK_RETURN_STRING_INACTIVE = config.FEEDBACK_RETURN_STRING_INACTIVE
local FEEDBACK_RETURN_STRING_NEITHER = config.FEEDBACK_RETURN_STRING_NEITHER
local FEEDBACK_RETURN_STRING_ELSE = config.FEEDBACK_RETURN_STRING_ELSE

  --Action config

local ACTIVATE_REDSTONE_SIDE = config.ACTIVATE_REDSTONE_SIDE
local DEACTIVATE_REDSTONE_SIDE = config.DEACTIVATE_REDSTONE_SIDE
local PULSE_REDSTONE_SIDE = config.PULSE_REDSTONE_SIDE
local PULSE_TIME = config.PULSE_TIME

-- === STATE ===
local currentAction = "deactivate"

-- === STATUS ===
local function getStatus(action)

    -- No Feedback ON
    if not FEEDBACK_ACTIVE_ON and not FEEDBACK_INACTIVE_ON then
        return "no feedback activated"
    end
    
    -- Feedback ACTIVE on
    if FEEDBACK_ACTIVE_ON and not FEEDBACK_INACTIVE_ON then
        
        if redstone.getInput(FEEDBACK_SIDE_ACTIVE) and action == "activate" then
            return FEEDBACK_RETURN_STRING_ACTIVE
        else
            return FEEDBACK_RETURN_STRING_INACTIVE
        end
  
    end
    
    -- Feedback INACTIVE on
    if FEEDBACK_INACTIVE_ON and not FEEDBACK_ACTIVE_ON then
        if redstone.getInput(FEEDBACK_SIDE_INACTIVE) and action == "deactivate" then
            return FEEDBACK_RETURN_STRING_INACTIVE
        else
            return FEEDBACK_RETURN_STRING_ACTIVE
        end        
    end
    
    -- Both Feedbacks on
    if FEEDBACK_ACTIVE_ON and FEEDBACK_INACTIVE_ON then
        if redstone.getInput(FEEDBACK_SIDE_ACTIVE) and action == "activate" then
            return FEEDBACK_RETURN_STRING_ACTIVE
    
        elseif redstone.getInput(FEEDBACK_SIDE_INACTIVE) and action == "deactivate" then
            return FEEDBACK_RETURN_STRING_INACTIVE
    
        elseif not redstone.getInput(FEEDBACK_SIDE_ACTIVE)
           and not redstone.getInput(FEEDBACK_SIDE_INACTIVE)
           and (action == "activate" or action == "deactivate") then
            return FEEDBACK_RETURN_STRING_NEITHER
    
        else
            return FEEDBACK_RETURN_STRING_ELSE
        end
    end
    
end

-- === ACTIONS ===
local function activate()
    if ACTIVATE_REDSTONE_SIDE ~= "" then
        redstone.setOutput(ACTIVATE_REDSTONE_SIDE, true)
    end
end

local function deactivate()
    if ACTIVATE_REDSTONE_SIDE ~= "" then
        redstone.setOutput(ACTIVATE_REDSTONE_SIDE, false)
    end
end

local function pulse()
    if PULSE_REDSTONE_SIDE ~= "" then    
        redstone.setOutput(PULSE_REDSTONE_SIDE, true)
        sleep(PULSE_TIME)
        redstone.setOutput(PULSE_REDSTONE_SIDE, false)
    end
end

-- === MESSAGE HANDLER ===
local function handle(msg, sender, protocol)
    if protocol ~= PROTOCOL then return false end

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
        id = HOSTNAME,
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
