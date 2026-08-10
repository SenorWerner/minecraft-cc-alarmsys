-- =========================================================
-- CC ALARM SYSTEM
-- MAIN
-- =========================================================

local network =
    require("/core/network")

local sm =
    require("/core/service_manager")


-- =========================================================
-- WORKING DIRECTORY
-- =========================================================

shell.setDir("/")


-- =========================================================
-- MODEM
-- =========================================================

local modem =
    peripheral.find("modem")

if not modem then
    error("Kein Modem gefunden!")
end

rednet.open(
    peripheral.getName(modem)
)


-- =========================================================
-- CORE CONFIG
-- =========================================================

local config =
    require("/config/config")


rednet.host(
    "computer",
    config.HOSTNAME
)


print("==============================")
print("CC Alarm System")
print("==============================")
print("Hostname:", config.HOSTNAME)
print()


-- =========================================================
-- SERVICE STATUS
-- =========================================================

local status =
    require("/config/service_status")


-- =========================================================
-- SERVICE LOADER
-- =========================================================

local function loadService(
    name,
    path
)

    print(
        "Lade Service:",
        name
    )

    -- -----------------------------------------------------
    -- Service laden
    -- -----------------------------------------------------

    local ok, service =
        pcall(
            require,
            path
        )

    if not ok then

        term.setTextColor(colors.red)

        print(
            "[SERVICE LOAD ERROR]",
            name
        )

        print(service)

        term.setTextColor(colors.white)

        return false
    end


    -- -----------------------------------------------------
    -- Prüfen, ob Service eine Tabelle zurückgibt
    -- -----------------------------------------------------

    if type(service) ~= "table" then

        print(
            "[SERVICE ERROR]",
            name,
            "gibt keine Tabelle zurück."
        )

        return false
    end


    -- -----------------------------------------------------
    -- Service aktiviert?
    -- -----------------------------------------------------

    if not status[name] then

        print(
            "Service deaktiviert:",
            name
        )

        return true
    end


    -- -----------------------------------------------------
    -- NETWORK HANDLER
    -- -----------------------------------------------------

    if service.handle then

        if type(service.handle) == "function" then

            local registered =
                network.register(
                    service.handle
                )

            if registered then

                print(
                    "  Handler registriert."
                )

            end

        else

            print(
                "[SERVICE ERROR]",
                name,
                "handle ist keine Funktion."
            )
        end
    end


    -- -----------------------------------------------------
    -- BACKGROUND SERVICE
    -- -----------------------------------------------------

    if service.run then

        if type(service.run) == "function" then

            local registered =
                sm.add(
                    name,
                    service.run
                )

            if registered then

                print(
                    "  Run-Service registriert."
                )

            end

        else

            print(
                "[SERVICE ERROR]",
                name,
                "run ist keine Funktion."
            )
        end
    end


    print(
        "Service aktiviert:",
        name
    )

    return true
end


-- =========================================================
-- SERVICES LADEN
-- =========================================================

if not fs.exists("/services") then

    print(
        "WARNUNG: /services existiert nicht."
    )

else

    for _, entry in ipairs(
        fs.list("/services")
    ) do

        local path =
            fs.combine(
                "/services",
                entry
            )


        -- =================================================
        -- PAKET
        --
        -- /services/gateDriver/
        --     gateDriver.lua
        --     config_gateDriver.lua
        -- =================================================

        if fs.isDir(path) then

            local mainFile =
                fs.combine(
                    path,
                    entry .. ".lua"
                )


            if fs.exists(mainFile) then

                local modulePath =
                    "/" ..
                    mainFile:gsub(
                        "%.lua$",
                        ""
                    )

                loadService(
                    entry,
                    modulePath
                )

            else

                print(
                    "[SERVICE ERROR]",
                    "Keine Main-Datei gefunden:",
                    mainFile
                )
            end


        -- =================================================
        -- EINZELNE LUA DATEI
        --
        -- /services/heartbeat.lua
        -- =================================================

        elseif entry:sub(-4) == ".lua" then

            local name =
                entry:gsub(
                    "%.lua$",
                    ""
                )

            local modulePath =
                "/services/" .. name

            loadService(
                name,
                modulePath
            )
        end
    end
end


-- =========================================================
-- SYSTEM STARTEN
-- =========================================================

print()
print("==============================")
print("Services geladen.")
print("Network + Service Manager starten...")
print("==============================")


parallel.waitForAll(
    network.run,
    sm.run
)
