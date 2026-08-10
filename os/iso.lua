-- === ISO INSTALLER ===

-- === INIT ===
term.clear()
term.setCursorPos(1,1)

print("=== CC Alarm System OS Installer ===")

-- Modem prüfen
local modem = peripheral.find("modem")
if not modem then
    error("Kein Modem gefunden!")
end

rednet.open(peripheral.getName(modem))

-- === INPUT ===
write("Hostname: ")
local hostname = read()

write("Ist dieses Gerät ein ACTOR? (true/false): ")
local isActor = read() == "true"

write("Ist dieses Gerät ein SENSOR? (true/false): ")
local isSensor = read() == "true"

write("Comm Server Name: ")
local commServer = read()

write("DNS Server Name: ")
local dnsServer = read()

-- === DNS FINDEN ===
local function findDNSServer(name)
    local id = rednet.lookup("nameserver", name)
    if not id then
        print("DNS Server nicht gefunden!")
        return nil
    end
    return id
end

local dnsID = findDNSServer(dnsServer)
if not dnsID then return end

-- === NAME CHECK ===
local function checkName(name)
    rednet.send(dnsID, {
        action = "check",
        name = name
    }, "ns")

    local _, reply = rednet.receive("ns", 2)

    if not reply then
        return false, "DNS Timeout"
    end

    if not reply.ok then
        return false, "Name bereits vergeben"
    end

    return true
end

-- solange Name prüfen
while true do
    local ok, err = checkName(hostname)
    if ok then break end

    print("Fehler:", err)
    write("Neuer Hostname: ")
    hostname = read()
end

-- === REGISTER ===
local function register()
    local deviceType = "actor"
    if isSensor then deviceType = "sensor" end

    rednet.send(dnsID, {
        action = "register",
        name = hostname,
        type = deviceType
    }, "ns")

    local _, reply = rednet.receive("ns", 2)

    if not reply or not reply.ok then
        return false, reply and reply.error or "Register fehlgeschlagen"
    end

    return true
end

local ok, err = register()
if not ok then
    print("Registrierung fehlgeschlagen:", err)
    return
end

print("Erfolgreich beim DNS registriert!")

-- === CONFIG SCHREIBEN ===
fs.makeDir("config")

local configFile = fs.open("config/config.lua", "w")

configFile.write(string.format([[
return {
    HOSTNAME = "%s",
    ACTOR = %s,
    SENSOR = %s,
    COMM_SERVER = "%s",
    DNS_SERVER = "%s"
}
]], hostname, tostring(isActor), tostring(isSensor), commServer, dnsServer))

configFile.close()

-- Label setzen
os.setComputerLabel(hostname)

-- === OS DATEIEN INSTALLIEREN ===

local BASE_URL = "https://raw.githubusercontent.com/SenorWerner/minecraft-cc-alarmsys/refs/heads/main/"

local files = {
    "os/os/run.lua",
    "os/os/network.lua",
    "os/os/service_manager.lua",
    "os/os/updater.lua",
    "os/services/heartbeat.lua",
    "os/services/update_listener.lua"
}

local function download(path)
    print("Lade:", path)

    local res = http.get(BASE_URL .. path)
    if not res then
        error("Download fehlgeschlagen: " .. path)
    end

    local data = res.readAll()
    res.close()

    fs.makeDir(fs.getDir(path))

    local file = fs.open(path, "w")
    file.write(data)
    file.close()
end

for _, file in ipairs(files) do
    download(file)
end

-- === STARTUP ===
local startup = fs.open("startup.lua", "w")

startup.write([[
shell.run("os/run.lua")
]])

startup.close()

print("Installation abgeschlossen!")
print("Starte neu...")

sleep(2)
os.reboot()
