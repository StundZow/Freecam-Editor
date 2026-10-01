-- Distance d'affichage globale : decor, vehicules, pietons et ombres.
-- Tout est local : les autres joueurs ne voient aucun changement.

DrawDistance = {}

local REFRESH_MS = 500 -- les vehicules / pietons apparus entre-temps sont rattrapes a ce rythme

local touched = false

local entityScale = 1.0
local nextEntitiesAt = 0

local shadowScale = 1.0
local nextShadowsAt = 0

local function applyEntityLod(scale)
    local vehicles = GetGamePool('CVehicle')
    for i = 1, #vehicles do
        SetVehicleLodMultiplier(vehicles[i], scale)
    end

    local peds = GetGamePool('CPed')
    for i = 1, #peds do
        SetPedLodMultiplier(peds[i], scale)
    end

    SetFarDrawVehicles(scale > 1.0)
end

local function updateEntities(scale)
    if scale < 1.0 then scale = 1.0 end
    -- A x1 et rien d'applique : on ne touche a rien.
    if scale == 1.0 and entityScale == 1.0 then return end

    local now = GetGameTimer()
    if scale == entityScale and now < nextEntitiesAt then return end
    nextEntitiesAt = now + REFRESH_MS
    entityScale = scale
    applyEntityLod(scale)
end

local function updateShadows(scale)
    if scale < 1.0 then scale = 1.0 end
    if scale == 1.0 and shadowScale == 1.0 then return end

    local now = GetGameTimer()
    if scale == shadowScale and now < nextShadowsAt then return end
    nextShadowsAt = now + REFRESH_MS
    shadowScale = scale
    CascadeShadowsSetCascadeBoundsScale(scale)
end

-- A appeler a chaque image tant que la freecam est active.
function DrawDistance.update()
    touched = true

    -- Decor (batiments, terrain, arbres). A x1 le jeu garde son propre reglage.
    if Settings.lodScale > 1.0 then
        OverrideLodscaleThisFrame(Settings.lodScale)
    end

    updateEntities(Settings.lodScale)
    updateShadows(Settings.shadowScale)
end

-- Sans effet si rien n'a ete modifie : peut etre appele a chaque image.
function DrawDistance.restore()
    if not touched then return end
    touched = false

    updateEntities(1.0)
    updateShadows(1.0)
end
