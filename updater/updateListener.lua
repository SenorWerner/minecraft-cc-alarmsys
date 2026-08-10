local updater = require("updater")

local function handle(sender, msg, protocol)
    if type(msg) ~= "table" then return end
    if msg.action ~= "update" then return end

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

return {
    protocol = "update",
    handle = handle
}
