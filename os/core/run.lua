local network = require("/core/network")
local sm = require("/core/service_manager")

shell.setDir("/")

local modem = peripheral.find("modem")
rednet.open(peripheral.getName(modem))

local config = require("/config/config")
rednet.host("computer", config.HOSTNAME)

local status = require("/config/service_status")

for _, entry in ipairs(fs.list("services")) do
    local path = fs.combine("services", entry)

    -- =========================
    -- 📦 FALL 1: VERZEICHNIS
    -- =========================
    if fs.isDir(path) then
        local mainFile = fs.combine(path, entry .. ".lua")

        if fs.exists(mainFile) then
            print("Lade Paket-Service:", entry)

            local service = require("/" .. mainFile:gsub("%.lua$", ""))

            if status[entry] then
                if service.protocol then
                    network.register(service.protocol, service.handle)
                end

                if service.run then
                    sm.add(service.run)
                end
            else
                print("Service deaktiviert:", entry)
            end
        else
            print("WARNUNG: Keine Main-Datei für Paket:", entry)
        end

    -- =========================
    -- 📄 FALL 2: EINZELDATEI
    -- =========================
    elseif entry:sub(-4) == ".lua" then
        local name = entry:gsub("%.lua$", "")

        print("Lade Einzel-Service:", name)

        local service = require("/services/" .. name)

        if status[name] then
            if service.protocol then
                network.register(service.protocol, service.handle)
            end

            if service.run then
                sm.add(service.run)
            end
        else
            print("Service deaktiviert:", name)
        end
    end
end

parallel.waitForAll(
    network.run,
    sm.run
)
