local BASE_URL = "https://raw.githubusercontent.com/USER/REPO/main/"

local function download(path)
    local res = http.get(BASE_URL .. path)
    if not res then error("Download failed: " .. path) end
    local data = res.readAll()
    res.close()
    return data
end

local function save(path, data)
    fs.makeDir(fs.getDir(path))
    local f = fs.open(path, "w")
    f.write(data)
    f.close()
end

-- === SETUP ===
term.clear()
term.setCursorPos(1,1)

print("=== CC-OS Setup ===")

write("Hostname: ")
local hostname = read()

write("Comm Server Name: ")
local comm = read()

write("DNS Server Name: ")
local dns = read()

write("ACTOR (true/false): ")
local actor = read() == "true"

write("SENSOR (true/false): ")
local sensor = read() == "true"

-- === CONFIG ===
local config = string.format([[
return {
    HOSTNAME = "%s",
    COMM_SERVER = "%s",
    DNS_SERVER = "%s",
    ACTOR = %s,
    SENSOR = %s,
    AUTO_RUN = false
}
]], hostname, comm, dns, tostring(actor), tostring(sensor))

save("config/config.lua", config)

os.setComputerLabel(hostname)

-- === SERVICE STATUS DEFAULT ===
save("config/service_status.lua", [[
return {
    heartbeat = true,
    update_listener = true
}
]])

-- === DOWNLOAD CORE ===
local files = {
    "os/main.lua",
    "os/run.lua",
    "os/network.lua",
    "os/service_manager.lua",
    "os/updater.lua", 
    "services/heartbeat.lua",
    "services/update_listener.lua"
}

for _, file in ipairs(files) do
    print("Installing:", file)
    save(file, download(file))
end

-- === STARTUP ===
save("startup.lua", 'shell.run("os/main.lua")')

print("Installation complete!")
