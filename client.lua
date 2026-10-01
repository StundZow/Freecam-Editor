local active = false
local cam = nil

local pos = vector3(0.0, 0.0, 0.0)
local vel = vector3(0.0, 0.0, 0.0)

-- yaw/pitch = rotation affichee, targetYaw/targetPitch = rotation visee par la souris.
-- Hors mode smooth les deux sont identiques.
local yaw, pitch = 0.0, 0.0
local targetYaw, targetPitch = 0.0, 0.0

local wasVerticalLock = false

local feedbackText = ''
local feedbackUntil = 0

-- Controles GTA
local CTRL_LOOK_LR     = 1
local CTRL_LOOK_UD     = 2
local CTRL_MOVE_LR     = 30
local CTRL_MOVE_UD     = 31
local CTRL_SPRINT      = 21  -- Shift
local CTRL_MOVE_UP     = { 22, 38 } -- Espace, E
local CTRL_MOVE_DOWN   = { 36, 44 } -- Ctrl gauche, A (touche Q d'un clavier QWERTY)
local CTRL_SCROLL_UP   = { 241, 15 }
local CTRL_SCROLL_DOWN = { 242, 14 }
local CTRL_KEEP_ENABLED = { 200, 245, 249 } -- pause, chat, push-to-talk

local function anyJustPressed(controls)
    for i = 1, #controls do
        if IsDisabledControlJustPressed(0, controls[i]) then return true end
    end
    return false
end

local function anyPressed(controls)
    for i = 1, #controls do
        if IsDisabledControlPressed(0, controls[i]) then return true end
    end
    return false
end

local function showFeedback(text)
    if not Settings.showFeedback then return end
    feedbackText = text
    feedbackUntil = GetGameTimer() + 1200
end

local function drawFeedback()
    if GetGameTimer() > feedbackUntil then return end
    SetTextFont(4)
    SetTextScale(0.45, 0.45)
    SetTextColour(255, 255, 255, 220)
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(feedbackText)
    EndTextCommandDisplayText(0.5, 0.93)
end

local function hideHud()
    HideHudAndRadarThisFrame()
    ThefeedHideThisFrame()
    HideHelpTextThisFrame()
end

local function lockControls()
    DisableAllControlActions(0)
    for i = 1, #CTRL_KEEP_ENABLED do
        EnableControlAction(0, CTRL_KEEP_ENABLED[i], true)
    end
end

local function updateSpeed()
    local previous = Settings.speed
    local speed = previous
    if anyJustPressed(CTRL_SCROLL_UP) then
        speed = speed * Config.Speed.Step
    elseif anyJustPressed(CTRL_SCROLL_DOWN) then
        speed = speed / Config.Speed.Step
    end
    Settings.speed = Clamp(speed, Config.Speed.Min, Config.Speed.Max)
    if Settings.speed ~= previous then
        showFeedback(('Vitesse : %.1f m/s'):format(Settings.speed))
    end
end

local function updateRotation(dt)
    local lookX = GetDisabledControlNormal(0, CTRL_LOOK_LR)
    local lookY = GetDisabledControlNormal(0, CTRL_LOOK_UD)

    targetYaw = targetYaw - lookX * Settings.sensitivity
    targetPitch = Clamp(targetPitch - lookY * Settings.sensitivity, -89.0, 89.0)

    if Settings.smooth then
        local t = 1.0 - math.exp(-Settings.smoothRotation * dt)
        yaw = yaw + (targetYaw - yaw) * t
        pitch = pitch + (targetPitch - pitch) * t
    else
        yaw, pitch = targetYaw, targetPitch
    end
end

local function updatePosition(dt)
    local radZ, radX = math.rad(yaw), math.rad(pitch)

    -- Au passage en vertical lock, on coupe l'elan vertical restant du mode smooth
    -- pour ne pas deriver en hauteur.
    if Settings.verticalLock and not wasVerticalLock then
        vel = vector3(vel.x, vel.y, 0.0)
    end
    wasVerticalLock = Settings.verticalLock

    -- En vertical lock on ignore l'inclinaison : avancer reste a hauteur constante.
    local forward
    if Settings.verticalLock then
        forward = vector3(-math.sin(radZ), math.cos(radZ), 0.0)
    else
        local cosX = math.cos(radX)
        forward = vector3(-math.sin(radZ) * cosX, math.cos(radZ) * cosX, math.sin(radX))
    end
    local right = vector3(math.cos(radZ), math.sin(radZ), 0.0)

    local moveForward = -GetDisabledControlNormal(0, CTRL_MOVE_UD)
    local moveRight = GetDisabledControlNormal(0, CTRL_MOVE_LR)
    local moveUp = 0.0
    if anyPressed(CTRL_MOVE_UP) then moveUp = moveUp + 1.0 end
    if anyPressed(CTRL_MOVE_DOWN) then moveUp = moveUp - 1.0 end

    local dir = forward * moveForward + right * moveRight + vector3(0.0, 0.0, moveUp)
    local length = #dir
    if length > 1.0 then dir = dir / length end

    local currentSpeed = Settings.speed
    if IsDisabledControlPressed(0, CTRL_SPRINT) then
        currentSpeed = currentSpeed * Config.Speed.Boost
    end
    local targetVel = dir * currentSpeed

    if Settings.smooth then
        local t = 1.0 - math.exp(-Settings.smoothMovement * dt)
        vel = vel + (targetVel - vel) * t
    else
        vel = targetVel
    end

    pos = pos + vel * dt
end

local function applyCamera()
    SetCamCoord(cam, pos.x, pos.y, pos.z)
    SetCamRot(cam, pitch, 0.0, yaw % 360.0, 2)
    SetCamFov(cam, Settings.fov)
    -- Charge la map autour de la camera plutot qu'autour du perso reste sur place.
    SetFocusPosAndVel(pos.x, pos.y, pos.z, vel.x, vel.y, vel.z)
end

local function stopFreecam()
    if not active then return end
    active = false

    -- La camera est rendue en premier : quoi qu'il arrive ensuite, le joueur n'est pas coince.
    RenderScriptCams(false, false, 0, true, true)
    DestroyCam(cam, false)
    cam = nil
    ClearFocus()

    Menu.open = false
    SaveSettings()
    CleanSky.restore()
    DrawDistance.restore()
end

-- Une image de freecam.
local function tick()
    hideHud()

    if Settings.hidePed then
        SetEntityLocallyInvisible(PlayerPedId())
    end

    if Settings.graphics then
        CleanSky.update(cam)
        DrawDistance.update()
    else
        CleanSky.restore(cam)
        DrawDistance.restore()
    end

    -- Menu pause ouvert : on laisse les controles libres pour pouvoir y naviguer.
    if not IsPauseMenuActive() then
        lockControls()
        local dt = GetFrameTime()
        updateSpeed()
        updateRotation(dt)
        updatePosition(dt)
        applyCamera()
        Menu.update()
    end

    drawFeedback()
end

local function startFreecam()
    if active then return end

    pos = GetFinalRenderedCamCoord()
    vel = vector3(0.0, 0.0, 0.0)

    local rot = GetFinalRenderedCamRot(2)
    yaw, pitch = rot.z, Clamp(rot.x, -89.0, 89.0)
    targetYaw, targetPitch = yaw, pitch
    wasVerticalLock = Settings.verticalLock

    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    applyCamera()
    RenderScriptCams(true, false, 0, true, true)

    active = true

    CreateThread(function()
        while active do
            -- Une erreur ne doit pas laisser la camera bloquee : on coupe proprement.
            local ok, err = pcall(tick)
            if not ok then
                print(('^1[broll_freecam] erreur, freecam coupee : %s^7'):format(err))
                stopFreecam()
            end
            Wait(0)
        end
    end)
end

local function toggleFreecam()
    if active then
        stopFreecam()
    else
        startFreecam()
    end
end

RegisterNetEvent('broll_freecam:toggle', toggleFreecam)

RegisterCommand('freecam', function()
    -- On peut toujours sortir de la freecam ; seule l'activation passe par la permission.
    if Config.AcePermission and not active then
        TriggerServerEvent('broll_freecam:requestToggle')
    else
        toggleFreecam()
    end
end, false)

RegisterCommand('freecam_menu', function()
    if not active then return end
    Menu.toggle()
end, false)

RegisterCommand('freecam_vlock', function()
    if not active then return end
    Settings.verticalLock = not Settings.verticalLock
    showFeedback('Verrouillage vertical : ' .. (Settings.verticalLock and 'ON' or 'OFF'))
end, false)

-- Raccourci facultatif pour le smooth, sans touche par defaut (a assigner en jeu si besoin).
RegisterCommand('freecam_lissage', function()
    if not active then return end
    Settings.smooth = not Settings.smooth
    showFeedback('Smooth : ' .. (Settings.smooth and 'ON' or 'OFF'))
end, false)

RegisterKeyMapping('freecam', 'Freecam B-roll - ON/OFF', 'keyboard', Config.Keys.Toggle)
RegisterKeyMapping('freecam_menu', 'Freecam B-roll - Menu de reglages', 'keyboard', Config.Keys.Menu)
RegisterKeyMapping('freecam_vlock', 'Freecam B-roll - Verrouillage vertical', 'keyboard', Config.Keys.VerticalLock)
RegisterKeyMapping('freecam_lissage', 'Freecam B-roll - Camera smooth (raccourci)', 'keyboard', '')

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        stopFreecam()
    end
end)
