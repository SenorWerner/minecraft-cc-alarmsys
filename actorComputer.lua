-- === INIT ===
local modem = peripheral.find("modem")
if not modem then error("Kein Modem gefunden") end
rednet.open(peripheral.getName(modem))

local config = require("config")

local HOST_ID = config.HOST_ID
local HOST_NAME = config.HOST_NAME
local COMM_SERVER_ID = config.COMM_SERVER_ID

 
rednet.host("computer", HOST_ID)
 
print("Gate-System gestartet...")
 
local currentAction = "deactivate"
 
 
-- === CONFIG ===
local PULSE_TIME = 1
 
-- === STATUS FUNCTION ===
local function getStatus(action)
    if redstone.getInput("right") and action == "activate" then
        return "active"
    elseif redstone.getInput("right") == false and action == "activate" then
        return "moving"
    elseif redstone.getInput("right") and action == "deactivate" then
       return "moving"
    else 
        return "inactive"
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
 
-- === MAIN LOOP ===
while true do
    local sender, msg = rednet.receive()
 
    if type(msg) == "table" and msg.id == HOST_ID and msg.action then
        
        if msg.action == "activate" then
            currentAction = "activate"
            activate()
 
        elseif msg.action == "deactivate" then
            currentAction = "deactivate"
            deactivate()
 
        elseif msg.action == "pulse" then
            pulse()
 
        elseif msg.action == "status" then
            -- nichts ausführen, nur Status zurückgeben
        end
 
        -- === STATUS ANTWORT ===
        rednet.send(sender, {
            id = HOST_ID,
            status = getStatus(currentAction)
        })
        print(getStatus(currentAction), currentAction)
    end
end
