-- === CONFIG ===
local BASE_URL = "https://raw.githubusercontent.com/USER/REPO/main/"
local BACKUP_DIR = "/backup"
local TEMP_DIR = "/temp"

-- === HELPERS ===

local function clearDir(path)
    if fs.exists(path) then
        fs.delete(path)
    end
end

local function ensureDir(path)
    if not fs.exists(path) then
        fs.makeDir(path)
    end
end

local function copyFile(src, dst)
    local inFile = fs.open(src, "r")
    local outFile = fs.open(dst, "w")

    outFile.write(inFile.readAll())

    inFile.close()
    outFile.close()
end

local function download(url)
    local h = http.get(url)
    if not h then return nil end
    local data = h.readAll()
    h.close()
    return data
end

-- === BACKUP ===

local function backupFiles(files)
    clearDir(BACKUP_DIR)
    ensureDir(BACKUP_DIR)

    for _, file in ipairs(files) do
        if fs.exists(file) then
            local dst = fs.combine(BACKUP_DIR, file)
            ensureDir(fs.getDir(dst))
            copyFile(file, dst)
        end
    end
end

local function restoreBackup()
    if not fs.exists(BACKUP_DIR) then return end

    for _, file in ipairs(fs.list(BACKUP_DIR)) do
        local src = fs.combine(BACKUP_DIR, file)
        local dst = file

        if fs.isDir(src) then
            fs.copy(src, dst)
        else
            copyFile(src, dst)
        end
    end
end

-- === DOWNLOAD FILES ===

local function downloadFiles(files)
    clearDir(TEMP_DIR)
    ensureDir(TEMP_DIR)

    for _, file in ipairs(files) do
        -- config NIE überschreiben
        if not string.find(file, "config_") then
            local url = BASE_URL .. file
            print("Download:", file)

            local data = download(url)
            if not data then
                return false, "HTTP Fehler bei " .. file
            end

            local path = fs.combine(TEMP_DIR, file)
            ensureDir(fs.getDir(path))

            local f = fs.open(path, "w")
            f.write(data)
            f.close()
        end
    end

    return true
end

-- === APPLY UPDATE ===

local function applyFiles(files)
    for _, file in ipairs(files) do
        if not string.find(file, "config_") then
            local src = fs.combine(TEMP_DIR, file)

            if fs.exists(src) then
                ensureDir(fs.getDir(file))
                fs.copy(src, file)
            end
        end
    end
end

-- === MANIFEST ===

local function loadManifest(package)
    local path = package .. "/manifest.lua"
    local url = BASE_URL .. path

    local data = download(url)
    if not data then return nil end

    local fn = load(data)
    if not fn then return nil end

    return fn()
end

-- === UPDATE LOGIC ===

local function updatePackage(package)
    print("Update Paket:", package)

    local manifest = loadManifest(package)
    if not manifest or not manifest.files then
        return false, "Manifest Fehler"
    end

    local files = manifest.files

    backupFiles(files)

    local ok, err = downloadFiles(files)
    if not ok then
        restoreBackup()
        return false, err
    end

    applyFiles(files)

    clearDir(BACKUP_DIR)
    clearDir(TEMP_DIR)

    return true
end

local function updateFile(file)
    print("Update Datei:", file)

    backupFiles({file})

    local data = download(BASE_URL .. file)
    if not data then
        restoreBackup()
        return false, "HTTP Fehler"
    end

    if not string.find(file, "config_") then
        ensureDir(fs.getDir(file))

        local f = fs.open(file, "w")
        f.write(data)
        f.close()
    end

    clearDir(BACKUP_DIR)

    return true
end

-- === MAIN ENTRY ===

local function run(frame)
    if (frame.package and frame.file) or (not frame.package and not frame.file) then
        return false, "Ungültiger Update Frame"
    end

    if frame.package then
        return updatePackage(frame.package)
    else
        return updateFile(frame.file)
    end
end

return {
    run = run
}
