-- Basis-URL zu deinem GitHub Repo (ANPASSEN!)
local BASE_URL = "https://raw.githubusercontent.com/SenorWerner/minecraft-cc-alarmsys/refs/heads/main/"

-- Argumente prüfen
local args = { ... }
if #args < 2 then
    print("Usage: update <zu_loeschende_datei> <neue_datei>")
    return
end

local oldFile = args[1]
local newFile = args[2]

-- Alte Datei löschen (falls vorhanden)
if fs.exists(oldFile) then
    fs.delete(oldFile)
    print("Gelöscht: " .. oldFile)
else
    print("Datei nicht gefunden: " .. oldFile)
end

-- URL für neue Datei bauen
local url = BASE_URL .. newFile

-- Datei herunterladen
print("Lade herunter: " .. url)
local response = http.get(url)

if not response then
    print("Fehler beim Download!")
    return
end

local content = response.readAll()
response.close()

-- Neue Datei speichern (unter gleichem Namen wie angegeben)
local file = fs.open(newFile, "w")
file.write(content)
file.close()

print("Gespeichert als: " .. newFile)
print("Update abgeschlossen ✅")
