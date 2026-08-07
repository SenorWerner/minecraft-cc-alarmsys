-- AlarmSoundProgram

-- Todo
-- Loop sauberer machen -> Sound Datei am Anfang in RAM laden, damit Loop besser durhc läuft

local dfpwm = require("cc.audio.dfpwm")
local speakers = { peripheral.find("speaker") }

if #speakers == 0 then
    error("Keine Speaker gefunden!")
end

print("Gefundene Speaker: " .. #speakers)
print("Warte auf Alarm...")

local alarmRunning = false

while true do
    os.pullEvent("redstone")

    if redstone.getInput("back") and not alarmRunning then
        alarmRunning = true
        print(">>> IMPERIALER ALARM <<<")

        while redstone.getInput("back") do
            local file = fs.open("ImperialAlarmSound.dfpwm", "rb")
            if not file then
                error("Datei 'ImperialAlarmSound.dfpwm' nicht gefunden!")
            end

            local decoder = dfpwm.make_decoder()

            while true do
                local chunk = file.read(16 * 1024)
                if not chunk then
                    break
                end

                local buffer = decoder(chunk)

                local functions = {}

                for _, speaker in ipairs(speakers) do
                    table.insert(functions, function()
                        while not speaker.playAudio(buffer) do
                            os.pullEvent("speaker_audio_empty")
                        end
                    end)
                end

                parallel.waitForAll(table.unpack(functions))

                -- Alarm sofort beenden, wenn das Signal weg ist
                if not redstone.getInput("back") then
                    break
                end
            end

            file.close()
        end

        print("Alarm beendet.")
    end

    -- Warten, bis das Signal wieder aus ist
    while redstone.getInput("back") do
        os.pullEvent("redstone")
    end

    alarmRunning = false
end
