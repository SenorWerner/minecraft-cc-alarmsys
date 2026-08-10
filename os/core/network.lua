-- =========================================================
-- NETWORK
-- =========================================================

local DEBUG = true

local handlers = {}

-- =========================================================
-- LOGGING
-- =========================================================

local function logIncoming(sender, protocol, msg)

    if not DEBUG then
        return
    end

    term.setTextColor(colors.green)

    write("[IN ] ")

    term.setTextColor(colors.white)

    print(
        "FROM:",
        sender,
        "PROTOCOL:",
        protocol or "-"
    )

    print(textutils.serialize(msg))
end


local function logOutgoing(target, protocol, msg)

    if not DEBUG then
        return
    end

    term.setTextColor(colors.red)

    write("[OUT] ")

    term.setTextColor(colors.white)

    print(
        "TO:",
        target,
        "PROTOCOL:",
        protocol or "-"
    )

    print(textutils.serialize(msg))
end


local function logError(message)

    term.setTextColor(colors.orange)

    print("[NETWORK ERROR]", message)

    term.setTextColor(colors.white)
end


-- =========================================================
-- REGISTER SERVICE HANDLER
-- =========================================================

local function register(handler)

    if type(handler) ~= "function" then
        logError("Versuch, ungültigen Handler zu registrieren.")
        return false
    end

    table.insert(handlers, handler)

    return true
end


-- =========================================================
-- SEND
-- =========================================================

local function send(target, msg, protocol)

    logOutgoing(
        target,
        protocol,
        msg
    )

    local ok, result = pcall(
        rednet.send,
        target,
        msg,
        protocol
    )

    if not ok then
        logError(
            "Fehler beim Senden: " .. tostring(result)
        )

        return false
    end

    return result
end


-- =========================================================
-- NETWORK LOOP
-- =========================================================

local function run()

    print("Network gestartet.")
    print("Registrierte Handler:", #handlers)

    while true do

        local ok, sender, msg, protocol =
            pcall(rednet.receive)

        -- -------------------------------------------------
        -- Fehler beim Receive
        -- -------------------------------------------------

        if not ok then

            logError(
                "rednet.receive(): " .. tostring(sender)
            )

            sleep(1)

        else

            logIncoming(
                sender,
                protocol,
                msg
            )

            -- -------------------------------------------------
            -- Paket an ALLE registrierten Handler geben
            -- -------------------------------------------------

            for index, handler in ipairs(handlers) do

                local handlerOK, result =
                    pcall(
                        handler,
                        msg,
                        sender,
                        protocol
                    )

                -- ---------------------------------------------
                -- Handler hat einen Fehler verursacht
                -- ---------------------------------------------

                if not handlerOK then

                    logError(
                        "Handler " ..
                        tostring(index) ..
                        " Fehler: " ..
                        tostring(result)
                    )

                -- ---------------------------------------------
                -- Handler hat eine Antwort zurückgegeben
                -- ---------------------------------------------

                elseif result ~= nil
                    and result ~= false then

                    -- Nur Tabellen als Antwort akzeptieren
                    if type(result) == "table" then

                        send(
                            sender,
                            result,
                            protocol
                        )

                    else

                        logError(
                            "Handler " ..
                            tostring(index) ..
                            " hat keinen gültigen Response-Typ zurückgegeben."
                        )

                    end
                end
            end
        end
    end
end


-- =========================================================
-- EXPORT
-- =========================================================

return {
    register = register,
    send = send,
    run = run
}
