-- Reglages modifiables en jeu (menu G), memorises d'une session a l'autre.

local KVP_KEY = 'broll_freecam:settings'

function Clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

local function defaults()
    -- "+ 0.0" : les natives attendent des flottants, meme si config.lua contient un entier.
    return {
        speed          = Config.Speed.Default + 0.0,
        sensitivity    = Config.Sensitivity + 0.0,
        fov            = Config.Fov + 0.0,
        smooth         = false,
        smoothRotation = Config.Smooth.Rotation + 0.0,
        smoothMovement = Config.Smooth.Movement + 0.0,
        verticalLock   = false,
        graphics       = Config.Graphics,
        skyIntensity   = Config.Sky.Intensity + 0.0,
        clouds         = Config.Sky.Clouds + 0.0,
        forceSunny     = Config.Sky.ForceSunny,
        lodScale       = Config.LodScale + 0.0,
        shadowScale    = Config.ShadowScale + 0.0,
        hidePed        = Config.HidePed,
        showFeedback   = Config.ShowFeedback,
    }
end

Settings = defaults()

function LoadSettings()
    local raw = GetResourceKvpString(KVP_KEY)
    if not raw then return end

    local ok, saved = pcall(json.decode, raw)
    if not ok or type(saved) ~= 'table' then return end

    for key, default in pairs(Settings) do
        local value = saved[key]
        if type(value) == type(default) then
            if type(value) == 'number' then value = value + 0.0 end
            Settings[key] = value
        end
    end
end

function SaveSettings()
    SetResourceKvp(KVP_KEY, json.encode(Settings))
end

function ResetSettings()
    for key, value in pairs(defaults()) do
        Settings[key] = value
    end
end

LoadSettings()
