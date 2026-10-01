-- Ciel propre.
-- Vu de loin, la brume et les nuages du jeu noient l'image ; ici brume coupee,
-- nuages transparents, pas de pluie et distance de vue tres longue.
-- Trois reglages independants : intensite (brume), nuages, grand soleil force.
-- Tout est local : les autres joueurs ne voient aucun changement.

CleanSky = {}

local MODIFIER = 'broll_freecam_ciel_propre'
local FAR_CLIP = 60000.0
local FOG_START = 100000.0

local created = false
local fogApplied = false
local lastStrength = nil
local defaultFarClip = nil

local touched = false
local sunnyApplied = false
local nextReapplyAt = 0

local function setVar(name, value)
    pcall(SetTimecycleModifierVar, MODIFIER, name, value, 0.0)
end

local function createModifier()
    created = true
    if GetTimecycleModifierIndexByName(MODIFIER) < 0 then
        CreateTimecycleModifier(MODIFIER)
    end
    setVar('fog_density', 0.0)
    setVar('fog_falloff', 0.0)
    setVar('fog_base_height', 0.0)
    setVar('fog_haze_intensity', 0.0)
    setVar('far_clip', 50000.0)
end

local function restoreFog(cam)
    if not fogApplied then return end
    fogApplied = false

    ClearTimecycleModifier()
    SetFogVolumeRenderDisabled(false)
    if cam and DoesCamExist(cam) and defaultFarClip then
        SetCamFarClip(cam, defaultFarClip)
    end
end

-- strength : 0.0 (brume normale du jeu) a 1.0 (aucune brume)
local function updateFog(cam, strength)
    if strength <= 0.0 then
        restoreFog(cam)
        return
    end

    if not created then createModifier() end

    if strength ~= lastStrength then
        lastStrength = strength
        -- Le jeu melange chaque variable avec sa valeur normale selon l'intensite.
        -- Avec un debut de brume fixe a 100 km, ce melange la repousserait hors de la
        -- carte des les premiers pourcents : on abaisse donc la cible aux faibles intensites.
        setVar('fog_start', FOG_START * strength ^ 5)
    end

    if not fogApplied then
        fogApplied = true
        defaultFarClip = GetCamFarClip(cam)
        SetCamFarClip(cam, FAR_CLIP)
        SetFogVolumeRenderDisabled(true)
    end

    -- Le filtre d'image doit etre remis a chaque image.
    SetTimecycleModifier(MODIFIER)
    SetTimecycleModifierStrength(strength)
end

local function restoreSunny()
    if not sunnyApplied then return end
    sunnyApplied = false
    ClearOverrideWeather()
    SetRainLevel(-1.0)
end

-- A appeler a chaque image tant que la freecam est active.
function CleanSky.update(cam)
    touched = true
    updateFog(cam, Settings.skyIntensity / 100.0)
    SetCloudsAlpha(Settings.clouds / 100.0)

    if not Settings.forceSunny then
        restoreSunny()
    elseif not sunnyApplied then
        nextReapplyAt = 0
    end

    -- Reapplique chaque seconde (la synchro meteo du serveur le remettrait).
    if GetGameTimer() < nextReapplyAt then return end
    nextReapplyAt = GetGameTimer() + 1000

    if Settings.forceSunny then
        sunnyApplied = true
        SetOverrideWeather('EXTRASUNNY')
        SetRainLevel(0.0)
    end
    if fogApplied then
        SetFogVolumeRenderDisabled(true)
    end
end

-- Sans effet si rien n'a ete modifie : peut etre appele a chaque image.
function CleanSky.restore(cam)
    if not touched then return end
    touched = false

    restoreFog(cam)
    restoreSunny()
    SetCloudsAlpha(1.0)
    nextReapplyAt = 0
end
