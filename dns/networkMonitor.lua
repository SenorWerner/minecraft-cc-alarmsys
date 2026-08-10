rednet.open("right")

while true do
    local nsID = rednet.lookup("nameserver", "main")

    rednet.send(nsID, {
        action = "resolve_all"
    }, "ns")

    local _, reply = rednet.receive("ns", 2)

    term.clear()
    term.setCursorPos(1,1)

    print("=== SYSTEM STATUS ===\n")

    if reply and reply.ok then
        for _, entry in pairs(reply.list) do
            print(
                entry.name .. " | " ..
                entry.type .. " | " ..
                (entry.online and "ONLINE" or "OFFLINE")
            )
        end
    else
        print("Keine Antwort vom Nameserver")
    end

    sleep(2)
end
