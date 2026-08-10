-- === INIT ===
local modem = peripheral.find("modem")
if not modem then error("Kein Modem gefunden") end
rednet.open(peripheral.getName(modem))

local config = require("config")
rednet.host("computer", config.HOST_ID)

print("System startet...")

-- === LOAD ===
local network = require("network")

local gate = require("services.gate")
local updater = require("services.update_listener")
local heartbeat = require("services.heartbeat")

-- === REGISTER SERVICES ===
network.register(gate.protocol, gate.handle)
network.register(updater.protocol, updater.handle)

-- === SAFETY WRAPPER ===
local function safe(fn, name)
    return function()
        while true do
            local ok, err = pcall(fn)
            if not ok then
                print("Fehler in " .. name .. ": " .. err)
                sleep(2)
            end
        end
    end
end

-- === START ===
parallel.waitForAll(
    safe(network.run, "network"),
    safe(heartbeat.run, "heartbeat")
)
