local services = {}

local function add(fn)
    table.insert(services, fn)
end

local function run()
    local wrapped = {}

    for i, fn in ipairs(services) do
        wrapped[i] = function()
            while true do
                local ok, err = pcall(fn)
                if not ok then
                    print("Service crashed:", err)
                    sleep(2)
                end
            end
        end
    end

    parallel.waitForAll(table.unpack(wrapped))
end

-- UI MODE
if ... == nil then
    local status = require("/config/service_status")

    while true do
        term.clear()
        term.setCursorPos(1,1)

        print("Service Manager")
        for k,v in pairs(status) do
            print(k, v and "[ON]" or "[OFF]")
        end

        print("Toggle Service Name:")
        local name = read()

        if status[name] ~= nil then
            status[name] = not status[name]
        end

        local f = fs.open("config/service_status.lua","w")
        f.write("return " .. textutils.serialize(status))
        f.close()
    end
end

return {
    add = add,
    run = run
}
