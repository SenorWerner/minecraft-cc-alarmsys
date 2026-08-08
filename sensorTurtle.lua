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
    if turtle.detect() then
        return "active"
    else
        return "inactive"
    end
  end
 
-- === MAIN LOOP ===
while true do
    local sender, msg = rednet.receive()
    print(sender, type(msg), msg.id, msg.action)
        if type(msg) == "table" and msg.id == HOST_ID and msg.action == "status" then
        
        local status = getStatus()
        
        replyMsg={
            id =HOST_ID, 
            action = "status",
            status = getStatus()
        }
        
        rednet.send(sender, replyMsg)
 
        print("Status gesendet:")
 
        print("An:", sender)
        print("Host_ID:", replyMsg.id)
        print("status:", replyMsg.status)
        print("action:" , replyMsg.action)
    end
end
