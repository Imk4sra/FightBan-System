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
-- Register the admin-only "fightban" command
RegisterCommand("fightban", function(source, args, rawCommand)
    local target = tonumber(args[1])
    local time = tonumber(args[2]) -- time in minutes

    if target and time then
        -- Store the ban info into the database and disable the weapon
        banAndDisableWeapon(target, time)
    else
        print("Usage: /fightban [player id] [time in minutes]")
    end
end, true)

-- Function to store the ban into the database and disable the weapon
function banAndDisableWeapon(target, time)
    local expireTime = os.time() + (time * 60) -- convert minutes to seconds

    -- Assuming MySQL-Async is being used
    MySQL.Async.execute("INSERT INTO fightbans (player_id, expire_time) VALUES (@player_id, @expire_time)",
    {
        ['@player_id'] = target,
        ['@expire_time'] = expireTime
    }, function(rowsChanged)
        if rowsChanged > 0 then
            -- Disable weapon for the target player
            TriggerClientEvent('disableWeapon', target, time)
        end
    end)
end

-- Function to check for expired bans (optional)
function checkForExpiredBans()
    local currentTime = os.time()

    MySQL.Async.fetchAll("SELECT * FROM fightbans WHERE expire_time <= @current_time", 
    {
        ['@current_time'] = currentTime
    }, function(results)
        for _, result in ipairs(results) do
            MySQL.Async.execute("DELETE FROM fightbans WHERE id = @id", { ['@id'] = result.id })
        end
    end)
end

-- You can run the above function at an interval if you want
-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(60000) -- every minute
--         checkForExpiredBans()
--     end
-- end)
```

### Client Side:

```lua
-- Event to disable the weapon on the client side
RegisterNetEvent("disableWeapon")
AddEventHandler("disableWeapon", function(time)
    local expireTime = os.time() + (time * 60) -- convert minutes to seconds

    Citizen.CreateThread(function()
        while os.time() <= expireTime do
            Citizen.Wait(0)
            DisableAllControlActions(1)
            EnableControlAction(1, 44, true) -- Enable Q key to allow running
        end
    end)
end)
```
### SQL Schema
```sql
USE `essentialmode`; -- if you using esx change essentialmode to es_extended
CREATE TABLE fightbans (
    id INT PRIMARY KEY AUTO_INCREMENT,
    player_id INT,
    expire_time INT
);
```
<h2>🛡️ License:</h2>

This project is licensed under the  [Hugs For Bugs Development](https://discord.gg/bFK5RR9upe)
