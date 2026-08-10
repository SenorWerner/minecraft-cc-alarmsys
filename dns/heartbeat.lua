local config = require("config")

local function run()
    while true do
        local nsID = rednet.lookup("nameserver", "main")

        if nsID then
            rednet.send(nsID, {
                action = "heartbeat",
                name = config.HOST_ID
            }, "ns")
        end

        sleep(5)
    end
end

return {
    run = run
}
