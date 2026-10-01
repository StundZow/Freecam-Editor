RegisterNetEvent('broll_freecam:requestToggle', function()
    local src = source
    if not Config.AcePermission or IsPlayerAceAllowed(src, Config.AcePermission) then
        TriggerClientEvent('broll_freecam:toggle', src)
    end
end)
