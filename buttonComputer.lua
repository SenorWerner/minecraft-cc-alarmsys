-- === CONFIG ===
local config = require("config")

local HOST_ID = config.HOST_ID
local HOST_NAME = config.HOST_NAME
local TARGET_ID = config.TARGET_ID
local COMM_SERVER_ID = config.COMM_SERVER_ID
local SENSOR_ID = config.SENSOR_ID
 
-- === INIT ===
local modem = peripheral.find("modem")
if not modem then error("Kein Modem gefunden") end
rednet.open(peripheral.getName(modem))
 
local monitor = peripheral.find("monitor")
if not monitor then error("Kein Monitor gefunden") end
 
monitor.setTextScale(1)
 
-- === STATE ===
local currentStatus = "unknown"
local currentCommand = "deactivate"
 
-- === UI ===
local function draw()
    monitor.setBackgroundColor(colors.black)
    monitor.clear()
 
    local w, h = monitor.getSize()
 
    -- Titel
    monitor.setCursorPos(2, 1)
    monitor.setTextColor(colors.white)
    monitor.write("SYSTEM: " .. HOST_NAME)
 
    -- Status anzeigen
    monitor.setCursorPos(2, 3)
    if currentStatus == "active" then
        monitor.setTextColor(colors.green)
    elseif currentStatus == "inactive" then
        monitor.setTextColor(colors.red)
    else
        monitor.setTextColor(colors.yellow)
    end
    monitor.write("Status: " .. currentStatus)
    monitor.setCursorPos(2,4)
    if currentCommand == "activate" then
        monitor.setTextColor(colors.green)
    else
        monitor.setTextColor(colors.red)
    end
    monitor.write("Current Command: " .. currentCommand)
 
    -- Button zeichnen
    monitor.setCursorPos(2, 6)
    monitor.setBackgroundColor(colors.gray)
    monitor.setTextColor(colors.black)
    monitor.write("  TOGGLE  ")
end
 
-- === SEND ===
local function send(action)
    local target = rednet.lookup("computer", COMM_SERVER_ID)
    if not target then
        print("CommunicationComputer ", COMM_SERVER_ID, " nicht gefunden!")
        return
    end
 
    local msg = {
        sender = HOST_ID,
        id = TARGET_ID,
        action = action
    }
 
    rednet.send(target, msg)
end

local function requestStatus(action)
    local target = rednet.lookup("computer", COMM_SERVER_ID)
    if not target then
        print("CommunicationComputer ", COMM_SERVER_ID, " nicht gefunden!")
        return
    end
 
    local msg = {
        sender = HOST_ID,
        id = SENSOR_ID,
        action = action
    }
 
    rednet.send(target, msg)
end
 
-- === STATUS REQUEST LOOP ===
local function requestStatusLoop()
    while true do
        requestStatus("status")
        sleep(2)
    end
end
 
-- === RECEIVE LOOP ===
local function receiveLoop()
    while true do
        local sender, msg = rednet.receive()
 
        if type(msg) == "table" and msg.id == TARGET_ID and msg.status then
            currentStatus = msg.status
            draw()
        end
    end
end
 
-- === INPUT LOOP ===
local function inputLoop()
    while true do
        local event, side, x, y = os.pullEvent("monitor_touch")
 
        -- Button Bereich (angepasst an draw)
        if y >= 6 and y <= 7 then
            print("Button pressed")
            if currentCommand == "activate" then
                currentCommand = "deactivate"
                send("deactivate")
                send("pulse")
            elseif currentCommand == "deactivate" then
                currentCommand = "activate"
                send("activate")    
                send("pulse")
            end
        end
    end
end
 
-- === START ===
draw()
 
parallel.waitForAll(
    inputLoop,
    receiveLoop,
    requestStatusLoop
)
