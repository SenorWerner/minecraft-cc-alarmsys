-- AlarmStarter.lua

local monitor = peripheral.find("monitor")

if not monitor then
    error("Kein Monitor gefunden!")
end

monitor.setTextScale(3)

local alarm = false
local blink = false
local timer = nil

-- Kurzer Redstone-Impuls auf der rechten Seite
local function pulseRight()
    redstone.setOutput("right", true)
    sleep(0.2)
    redstone.setOutput("right", false)
end

local function draw()
    local w, h = monitor.getSize()

    if alarm then
        if blink then
            monitor.setBackgroundColor(colors.red)
            monitor.setTextColor(colors.white)
        else
            monitor.setBackgroundColor(colors.black)
            monitor.setTextColor(colors.red)
        end

        monitor.clear()

        local text = "ALARM"
        monitor.setCursorPos(math.floor((w - #text) / 2) + 1, math.floor(h / 2))
        monitor.write(text)

        monitor.setCursorPos(2, h)
        monitor.setTextColor(colors.white)
        monitor.write("Zum Ausschalten tippen")
    else
        monitor.setBackgroundColor(colors.black)
        monitor.clear()
        monitor.setTextColor(colors.lime)

        local text = "BEREIT"
        monitor.setCursorPos(math.floor((w - #text) / 2) + 1, math.floor(h / 2))
        monitor.write(text)

        monitor.setCursorPos(2, h)
        monitor.write("Zum Aktivieren tippen")
    end
end

draw()

while true do
    local event = { os.pullEvent() }

    if event[1] == "monitor_touch" then
        alarm = not alarm

        -- Dauerhaftes Signal auf der Rückseite
        redstone.setOutput("back", alarm)

        -- Kurzer Impuls auf der rechten Seite
        pulseRight()

        blink = false
        draw()

        if alarm then
            timer = os.startTimer(0.5)
        else
            timer = nil
        end

    elseif event[1] == "timer" and event[2] == timer then
        if alarm then
            blink = not blink
            draw()
            timer = os.startTimer(0.5)
        end
    end
end
