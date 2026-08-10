local network = require("os/network")
local sm = require("os/service_manager")

local modem = peripheral.find("modem")
rednet.open(peripheral.getName(modem))

local config = require("config/config")
rednet.host("computer", config.HOSTNAME)

local status = require("config/service_status")

for _, file in ipairs(fs.list("services")) do
    local name = file:gsub(".lua", "")
    local service = require("services/" .. name)

    if status[name] then
        if service.protocol then
            network.register(service.protocol, service.handle)
        end
        if service.run then
            sm.add(service.run)
        end
    end
end

parallel.waitForAll(
    network.run,
    sm.run
)
