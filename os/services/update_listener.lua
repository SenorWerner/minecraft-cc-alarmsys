local updater = require("os.updater")

local function handle(sender, msg)
    if msg.action ~= "update" then return end

    local ok, err = updater.run(msg)

    rednet.send(sender, {
        action = "update_result",
        ok = ok,
        error = err
    }, "update")

    if ok then os.reboot() end
end

return {
    protocol = "update",
    handle = handle
}
