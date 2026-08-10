-- === CONFIG ===
local DEBUG = true

-- === HANDLER REGISTRY ===
local handlers = {}

-- === LOGGING ===
local function logIn(sender, protocol, msg)
    if not DEBUG then return end

    term.setTextColor(colors.green)
    write("[IN ] ")
    term.setTextColor(colors.white)
    print(sender, protocol or "-")

    print(textutils.serialize(msg))
end

local function logOut(target, protocol, msg)
    if not DEBUG then return end

    term.setTextColor(colors.red)
    write("[OUT] ")
    term.setTextColor(colors.white)
    print(target, protocol or "-")

    print(textutils.serialize(msg))
end

-- === REGISTER ===
local function register(protocol, fn)
    if not handlers[protocol] then
        handlers[protocol] = {}
    end
    table.insert(handlers[protocol], fn)
end

-- === SEND WRAPPER ===
local function send(target, msg, protocol)
    logOut(target, protocol, msg)
    return rednet.send(target, msg, protocol)
end

-- === MAIN LOOP ===
local function run()
    while true do
        local sender, msg, protocol = rednet.receive()

        logIn(sender, protocol, msg)

        if handlers[protocol] then
            for _, fn in ipairs(handlers[protocol]) do
                local ok, err = pcall(fn, sender, msg, protocol)

                if not ok then
                    term.setTextColor(colors.orange)
                    print("[ERROR Handler]:", err)
                    term.setTextColor(colors.white)
                end
            end
        end
    end
end

-- === EXPORT ===
return {
    register = register,
    run = run,
    send = send
}
