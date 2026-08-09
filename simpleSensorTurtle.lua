-- === INIT === 

local config = require("config")
local SIGNAL_OUT_SIDE = config.SIGNAL_OUT_SIDE
 
print("Simple-Sensor-Turtle gestartet...")
 
-- === STATUS FUNCTION ===
local function getStatus()
    if turtle.detect() then
        redstone.setOutput(SIGNAL_OUT_SIDE, true)
        return "active"
    else
        redstone.setOutput(SIGNAL_OUT_SIDE, false)
        return "inactive"
    end
  end
 
-- === MAIN LOOP ===
while true do
  getStatus()
  sleep(1)
end
