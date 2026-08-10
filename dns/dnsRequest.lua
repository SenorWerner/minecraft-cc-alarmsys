local config = require("config")

local function heartbeatLoop()
    while true do
        local nsID = rednet.lookup("nameserver", "main")

        if nsID then
            rednet.send(nsID, {
                action = "heartbeat",
                name = config.id
            }, "ns")
        end

        sleep(5)
    end
end

parallel.run(heartbeatLoop, main)
