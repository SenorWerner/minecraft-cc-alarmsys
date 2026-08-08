-- === INIT ===
local modem = peripheral.find("modem")
if not modem then error("Kein Modem gefunden") end
rednet.open(peripheral.getName(modem))
 
rednet.host("computer", "comm_001")
 
print("CommunicationComputer gestartet...")
print("Unter ID:", rednet.lookup("computer", "comm_001"))
 
-- === CACHE ===
-- Speichert bekannte Systeme (optional für Performance)
local systemCache = {}
 
local function getSystemID(label)
    if systemCache[label] then
        return systemCache[label]
    end
 
    local id = rednet.lookup("computer", label)
    if id then
        print("Computer found")
        systemCache[label] = id
    else
        id = rednet.lookup("turtle" , label)
        print("turtle foudnd")
        systemCache[label] = id
    end
    return id
end
 
-- === MAIN LOOP ===
while true do
    local sender, msg = rednet.receive()
 
    if type(msg) == "table" and msg.id and msg.action then
        local targetLabel = msg.id
        local targetID = getSystemID(targetLabel)
 
        if not targetID then
            print("System nicht gefunden: " .. targetLabel)
            -- optional: Fehler zurücksenden
            rednet.send(sender, {
                id = targetLabel,
                status = "offline"
            })
        else
            -- Weiterleiten an Zielsystem
            rednet.send(targetID, msg)
            print(targetID, msg.id, msg.action)
            -- Wenn Status angefragt ? Antwort zurückleiten
            if msg.action == "status" then
                -- Warte auf Antwort vom System
                local replySender, reply = rednet.receive(2)
                
                if reply and type(reply) == "table" and reply.status then
                    -- zurück an ursprünglichen Sender
                    rednet.send(sender, reply)
                else
                    -- Timeout / keine Antwort
                    rednet.send(sender, {
                        id = targetLabel,
                        status = "unknown"
                    })
                end
            end
        end
    end
end
