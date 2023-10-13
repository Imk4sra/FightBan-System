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
