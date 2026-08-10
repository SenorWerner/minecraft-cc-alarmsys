local handlers = {}

local function register(protocol, fn)
    if not handlers[protocol] then
        handlers[protocol] = {}
    end
    table.insert(handlers[protocol], fn)
end

local function run()
    while true do
        local sender, msg, protocol = rednet.receive()

        if handlers[protocol] then
            for _, fn in ipairs(handlers[protocol]) do
                pcall(fn, sender, msg, protocol)
            end
        end
    end
end

return {
    register = register,
    run = run
}
