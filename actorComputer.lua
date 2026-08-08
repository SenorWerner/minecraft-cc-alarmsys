-- === INIT ===
local modem = peripheral.find("modem")
if not modem then error("Kein Modem gefunden") end
rednet.open(peripheral.getName(modem))

rednet.host("computer", "gate_001")

print("Gate-System gestartet...")

-- === CONFIG ===
local PULSE_TIME = 0.5

-- === STATUS FUNCTION ===
local function getStatus()
    if redstone.getInput("right") then
        return "active"
    else
        return "inactive"
    end
end

-- === ACTIONS ===
local function activate()
    redstone.setOutput("back", true)
end

local function deactivate()
    redstone.setOutput("front", true)
end

local function pulse()
    redstone.setOutput("left", true)
    sleep(PULSE_TIME)
    redstone.setOutput("left", false)
end

-- === MAIN LOOP ===
while true do
    local sender, msg = rednet.receive()

    if type(msg) == "table" and msg.id == "gate_001" and msg.action then
        
        if msg.action == "activate" then
            activate()

        elseif msg.action == "deactivate" then
            deactivate()

        elseif msg.action == "pulse" then
            pulse()

        elseif msg.action == "status" then
            -- nichts ausführen, nur Status zurückgeben
        end

        -- === STATUS ANTWORT ===
        rednet.send(sender, {
            id = "gate_001",
            status = getStatus()
        })
    end
end
