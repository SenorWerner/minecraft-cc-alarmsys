-- === INIT ===
local modem = peripheral.find("modem")
if not modem then error("Kein Modem gefunden") end
rednet.open(peripheral.getName(modem))

local config = require("config")

local HOST_ID = config.HOST_ID

rednet.host("turtle", HOST_ID)

print("Sensor-Turtle gestartet...")

-- === STATUS FUNCTION ===
local function getStatus()
    local front = turtle.detect()
    local up = turtle.detectUp()
    local down = turtle.detectDown()

    return {
        front = front,
        up = up,
        down = down
    }
end

-- === MAIN LOOP ===
while true do
    local sender, msg = rednet.receive()

    if type(msg) == "table" and msg.id == HOST_ID and msg.action == "status" then
        
        local status = getStatus()

        rednet.send(sender, {
            id = HOST_ID,
            status = status
        })

        print("Status gesendet:")
        print("Front:", status.front, "Up:", status.up, "Down:", status.down)
    end
end
