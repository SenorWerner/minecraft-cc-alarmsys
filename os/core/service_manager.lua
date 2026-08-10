-- =========================================================
-- SERVICE MANAGER
-- =========================================================

local services = {}


-- =========================================================
-- REGISTER SERVICE
-- =========================================================

local function add(name, fn)

    if type(fn) ~= "function" then
        print(
            "[SERVICE MANAGER] Ungültiger Service:",
            name
        )

        return false
    end

    table.insert(services, {
        name = name,
        run = fn
    })

    return true
end


-- =========================================================
-- SERVICE WRAPPER
-- =========================================================

local function startService(service)

    while true do

        print(
            "[SERVICE START]",
            service.name
        )

        local ok, err = pcall(service.run)

        if not ok then

            term.setTextColor(colors.orange)

            print(
                "[SERVICE CRASH]",
                service.name
            )

            print(err)

            term.setTextColor(colors.white)

            print(
                "Neustart in 2 Sekunden..."
            )

            sleep(2)

        else

            -- Ein normal zurückkehrender Service
            -- wird ebenfalls neu gestartet.
            print(
                "[SERVICE STOP]",
                service.name
            )

            print(
                "Service wird neu gestartet..."
            )

            sleep(2)
        end
    end
end


-- =========================================================
-- MAIN
-- =========================================================

local function run()

    print(
        "Service Manager gestartet."
    )

    local processes = {}

    for _, service in ipairs(services) do

        table.insert(
            processes,

            function()
                startService(service)
            end
        )
    end

    if #processes == 0 then

        print(
            "Keine Hintergrund-Services registriert."
        )

        while true do
            sleep(60)
        end
    end

    parallel.waitForAll(
        table.unpack(processes)
    )
end


-- =========================================================
-- EXPORT
-- =========================================================

return {
    add = add,
    run = run
}
