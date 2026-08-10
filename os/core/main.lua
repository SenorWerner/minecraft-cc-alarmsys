local config = require("/config/config")

local function menu()
    while true do
        term.clear()
        term.setCursorPos(1,1)

        print("=== CC-OS ===")
        print("1. Pakete installieren")
        print("2. Update")
        print("3. Pakete konfigurieren")
        print("4. Service Manager")
        print("5. Run")
        print("6. Reset")

        local choice = read()

        if choice == "5" then
            shell.run("core/run.lua")
        elseif choice == "6" then
            for _, file in ipairs(fs.list("/")) do
                if file ~= "iso.lua" then
                    fs.delete(file)
                end
            end
            os.setComputerLabel(nil)
            print("Reset complete")
            return
        elseif choice == "3" then
            for _, f in ipairs(fs.list("services")) do
                if string.find(f, "config_") then
                    shell.run("edit services/" .. f)
                end
            end
        elseif choice == "4" then
            shell.run("core/service_manager.lua")
        end
    end
end

if config.AUTO_RUN then
    shell.run("core/run.lua")
else
    menu()
end
