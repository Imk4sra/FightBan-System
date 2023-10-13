# Fight Ban System For Fivem
Creating a "fightban" command in FiveM using Lua involves several steps, from command parsing to database operations for SQL and then finally implementing the functionality for disabling weapons. Below is a simplified example that outlines how this might be done.

Firstly, make sure you have set up an SQL database to store banned players and their unban timestamps.
## Requirements
```
MySQL-Async
```

# Note
This is just a simple example and doesn't include several other important features like error handling, proper ban management, and so forth. You would also typically want to make this more secure, and might want to integrate it into an existing admin/moderation framework.

I hope this helps you on your journey to becoming a skilled developer, especially in the domain of FiveM scripting!

### Now, the Fight Ban code:

### Server Side:

```lua
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
```

### Client Side:

```lua
local isFightBanned = false
local timeRemaining = 0

RegisterNetEvent('fightBanStatus')
AddEventHandler('fightBanStatus', function(status, time)
    isFightBanned = status
    timeRemaining = time or 0
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if isFightBanned then
            DisablePlayerFiring(PlayerId(), true)
            
            if timeRemaining > 0 then
                TriggerEvent('chatMessage', "SYSTEM", {255, 0, 0}, "You are fight banned for " .. timeRemaining .. " more seconds.")
                timeRemaining = timeRemaining - 1
                Citizen.Wait(1000)
            else
                isFightBanned = false
            end
        end
    end
end)
```
### SQL Schema
```sql
USE `essentialmode`; -- if you using esx change essentialmode to es_extended
CREATE TABLE fight_ban (
  identifier VARCHAR(255),
  expire_time TIMESTAMP,
  PRIMARY KEY (identifier)
);
```
<h2>🛡️ License:</h2>

This project is licensed under the  [Hugs For Bugs Development](https://discord.gg/bFK5RR9upe)
