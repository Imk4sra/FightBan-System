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
