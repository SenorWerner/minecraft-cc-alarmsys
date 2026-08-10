-- === INIT ===
local modem = peripheral.find("modem")
if not modem then error("Kein Modem gefunden") end
rednet.open(peripheral.getName(modem))

rednet.host("nameserver", "main")

local DB_FILE = "names.db"
local db = {}

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

print("Namensserver gestartet")

-- === MAIN LOOP ===
while true do
    local sender, msg, protocol = rednet.receive("ns")

    if type(msg) == "table" then

        -- CHECK NAME
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
                    error = "Name bereits vergeben"
                }, "ns")
            else
                db[msg.name] = {
                    id = sender,
                    type = msg.type,
                    lastSeen = os.clock()
                }

                save()

                rednet.send(sender, {
                    ok = true
                }, "ns")

                print("Registriert:", msg.name)
            end

        -- LOOKUP
        elseif msg.action == "resolve" then
            local entry = db[msg.name]

            if entry then
                rednet.send(sender, {
                    ok = true,
                    id = entry.id,
                    type = entry.type
                }, "ns")
            else
                rednet.send(sender, {
                    ok = false
                }, "ns")
            end
        end
    end
end
