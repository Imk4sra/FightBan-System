local fightBanned = {}

RegisterCommand("fightban", function(source, args, rawCommand)
    local targetSrc = args[1]
    local time = tonumber(args[2])

    if targetSrc and time then
        local steamIdentifier = GetPlayerIdentifier(targetSrc, 0)
        local tokenCount = GetNumPlayerTokens(targetSrc)
        
        local combinedIdentifier = steamIdentifier
        
        if tokenCount > 0 then
            local token = GetPlayerToken(targetSrc, 0)
            combinedIdentifier = steamIdentifier .. "_" .. token
        end

        local expireTime = os.time() + (time * 60)
        fightBanned[combinedIdentifier] = expireTime

         MySQL.Async.execute("INSERT INTO fight_ban (identifier, expire_time) VALUES (@identifier, @expire_time)", {
             ['@identifier'] = combinedIdentifier,
             ['@expire_time'] = expireTime
         })
        
        TriggerClientEvent('fightBanStatus', targetSrc, true, time)
    end
end, true)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    local steamIdentifier = GetPlayerIdentifier(source, 0)
    local tokenCount = GetNumPlayerTokens(source)
    
    local combinedIdentifier = steamIdentifier

    if tokenCount > 0 then
        local token = GetPlayerToken(source, 0)
        combinedIdentifier = steamIdentifier .. "_" .. token
    end
    
    local currentTime = os.time()

    if fightBanned[combinedIdentifier] and fightBanned[combinedIdentifier] > currentTime then
        TriggerClientEvent('fightBanStatus', source, true, fightBanned[combinedIdentifier] - currentTime)
    else
        TriggerClientEvent('fightBanStatus', source, false)
    end
end)
