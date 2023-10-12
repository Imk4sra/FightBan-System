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
