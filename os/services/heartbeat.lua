local config = require("/config/config")

local function run()
    while true do
        local id = rednet.lookup("dns", config.DNS_SERVER)

        if id then
            rednet.send(id, {
                action = "heartbeat",
                name = config.HOSTNAME
            }, "ns")
        end

        sleep(5)
    end
end

return {
    run = run
}
