local updater = require("updater")

local function updateListener()
    while true do
        local sender, msg, protocol = rednet.receive("update")

        if type(msg) == "table" and msg.action == "update" then
            print("Update empfangen")

            local ok, err = updater.run(msg)

            rednet.send(sender, {
                action = "update_result",
                ok = ok,
                error = err
            }, "update")

            if ok then
                print("Neustart...")
                sleep(1)
                os.reboot()
            end
        end
    end
end

parallel.run(updateListener, main)
