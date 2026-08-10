-- === CONFIG ===
local BASE_URL = "https://raw.githubusercontent.com/SenorWerner/minecraft-cc-alarmsys/refs/heads/main/"

-- === HELPERS ===
local function download(url)
    local h = http.get(url)
    if not h then return nil end

    local data = h.readAll()
    h.close()
    return data
end

local function saveFile(path, data)
    local dir = fs.getDir(path)

    if dir and dir ~= "" and not fs.exists(dir) then
        fs.makeDir(dir)
    end

    local f = fs.open(path, "w")
    if not f then
        error("Konnte Datei nicht öffnen: " .. path)
    end

    f.write(data)
    f.close()
end

-- === INSTALL ===
local function install(packageName, subPath)
    print("Installiere Paket:", packageName)

    local basePath = "services/" .. packageName
    local mainFile = packageName .. ".lua"
    local configFile = "config_" .. packageName .. ".lua"

    -- Zielordner erstellen
    if not fs.exists(basePath) then
        fs.makeDir(basePath)
    end

    -- === URL BASIS BAUEN ===
    local repoPath = ""

    if subPath and subPath ~= "" then
        repoPath = subPath .. "/" .. packageName .. "/"
    else
        repoPath = packageName .. "/"
    end

    -- === MAIN FILE ===
    local mainUrl = BASE_URL .. repoPath .. mainFile
    print("Lade:", mainUrl)

    local mainData = download(mainUrl)
    if not mainData then
        print("FEHLER: Konnte main Datei nicht laden")
        return false
    end

    saveFile(fs.combine(basePath, mainFile), mainData)

    -- === CONFIG FILE ===
    local configUrl = BASE_URL .. repoPath .. configFile
    print("Lade:", configUrl)

    local configData = download(configUrl)
    if not configData then
        print("WARNUNG: Keine config Datei gefunden")
    else
        local configPath = fs.combine(basePath, configFile)

        if not fs.exists(configPath) then
            saveFile(configPath, configData)
        else
            print("Config existiert bereits → wird NICHT überschrieben")
        end
    end

    print("Paket installiert:", packageName)
    return true
end

-- === CLI ===
local args = {...}

if not args[1] then
    print("Usage: packageInstaller <paketname> [pfad]")
    print("Beispiel:")
    print(" packageInstaller sensor_ini")
    print(" packageInstaller sensor_ini driver")
    return
end

install(args[1], args[2])
