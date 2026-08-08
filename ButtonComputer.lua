-- === CONFIG ===
local SYSTEM_ID = "gate_001"
local COMM_LABEL = "comm_001"

-- === INIT ===
local modem = peripheral.find("modem")
if not modem then error("Kein Modem gefunden") end
rednet.open(peripheral.getName(modem))

local monitor = peripheral.find("monitor")
if not monitor then error("Kein Monitor gefunden") end

monitor.setTextScale(1)

-- === STATE ===
local currentStatus = "unknown"

-- === UI ===
local function draw()
    monitor.setBackgroundColor(colors.black)
    monitor.clear()

    local w, h = monitor.getSize()

    -- Titel
    monitor.setCursorPos(2, 1)
    monitor.setTextColor(colors.white)
    monitor.write("SYSTEM: " .. SYSTEM_ID)

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

    -- Button zeichnen
    monitor.setCursorPos(2, 6)
    monitor.setBackgroundColor(colors.gray)
    monitor.setTextColor(colors.black)
    monitor.write("  TOGGLE  ")
end

-- === SEND ===
local function send(action)
    local target = rednet.lookup("computer", COMM_LABEL)
    if not target then
        print("CommunicationComputer nicht gefunden!")
        return
    end

    local msg = {
        id = SYSTEM_ID,
        action = action
    }

    rednet.send(target, msg)
end

-- === STATUS REQUEST LOOP ===
local function requestStatusLoop()
    while true do
        send("status")
        sleep(2)
    end
end

-- === RECEIVE LOOP ===
local function receiveLoop()
    while true do
        local sender, msg = rednet.receive()

        if type(msg) == "table" and msg.id == SYSTEM_ID and msg.status then
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
        if y == 6 then
            if currentStatus == "active" then
                send("deactivate")
            else
                send("activate")
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
