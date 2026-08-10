-- === INIT ===
local modem = peripheral.find("modem")
if not modem then error("Kein Modem gefunden") end
rednet.open(peripheral.getName(modem))

rednet.host("nameserver", "main")

local DB_FILE = "names.db"
local db = {}

local TIMEOUT = 30 -- Sekunden bis offline

-- === LOAD ===
if fs.exists(DB_FILE) then
    local file = fs.open(DB_FILE, "r")
    db = textutils.unserialize(file.readAll()) or {}
    file.close()
end

-- === SAVE ===
local function save()
    local file = fs.open(DB_FILE, "w")
    file.write(textutils.serialize(db))
    file.close()
end

-- === CLEANUP ===
local function cleanup()
    local now = os.clock()

    for name, entry in pairs(db) do
        if now - (entry.lastSeen or 0) > TIMEOUT then
            entry.online = false
        else
            entry.online = true
        end
    end
end

print("Namensserver gestartet")

-- === MAIN LOOP ===
while true do
    cleanup()

    local sender, msg, protocol = rednet.receive("ns")

    if type(msg) == "table" then

        -- CHECK
        if msg.action == "check" then
            local exists = db[msg.name] ~= nil

            rednet.send(sender, {
                ok = not exists,
                exists = exists
            }, "ns")

        -- REGISTER
        elseif msg.action == "register" then
            if db[msg.name] then
                rednet.send(sender, {
                    ok = false,
                    error = "Name vergeben"
                }, "ns")
            else
                db[msg.name] = {
                    id = sender,
                    type = msg.type,
                    lastSeen = os.clock(),
                    online = true
                }

                save()

                rednet.send(sender, { ok = true }, "ns")
                print("Registriert:", msg.name)
            end
        end

        -- RESOLVE
        if msg.action == "resolve" then
            local entry = db[msg.name]

            if entry then
                rednet.send(sender, {
                    ok = true,
                    id = entry.id,
                    type = entry.type,
                    online = entry.online
                }, "ns")
            else
                rednet.send(sender, { ok = false }, "ns")
            end
        end

        -- RESOLVE ALL
        if msg.action == "resolve_all" then
            local result = {}

            for name, entry in pairs(db) do
                if (not msg.type or entry.type == msg.type) then
                    table.insert(result, {
                        name = name,
                        id = entry.id,
                        type = entry.type,
                        online = entry.online
                    })
                end
            end

            rednet.send(sender, {
                ok = true,
                list = result
            }, "ns")
        end

        -- HEARTBEAT (UPDATED!)
        if msg.action == "heartbeat" then
            if db[msg.name] then
                db[msg.name].lastSeen = os.clock()
                db[msg.name].online = true

                -- WICHTIG: ID AUTOMATISCH AKTUALISIEREN
                db[msg.name].id = sender
            end
        end
    end
end
