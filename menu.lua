-- Menu de reglages (touche G). Dessine par le script pour rester visible HUD cache,
-- et pilote aux fleches pour pouvoir continuer a voler et voir les changements en direct.

Menu = { open = false }

-- Controles GTA
local CTRL_UP     = 172 -- fleche haut
local CTRL_DOWN   = 173 -- fleche bas
local CTRL_LEFT   = 174 -- fleche gauche
local CTRL_RIGHT  = 175 -- fleche droite
local CTRL_ACCEPT = 201 -- Entree
local CTRL_BACK   = 194 -- Retour arriere

-- Mise en page (fractions de l'ecran)
local X, Y, W = 0.02, 0.06, 0.23
local PAD = 0.006
local TITLE_H, ROW_H, HELP_H, FOOTER_H = 0.05, 0.035, 0.055, 0.03

local selected = 1
local repeatAt = 0

local function toggleItem(label, key, help)
    local function flip() Settings[key] = not Settings[key] end
    return {
        label = label,
        help = help,
        value = function() return Settings[key] and 'ON' or 'OFF' end,
        change = flip,
        activate = flip,
    }
end

-- opts : format, min, max, puis step (addition) ou factor (multiplication)
local function numberItem(label, key, help, opts)
    return {
        label = label,
        help = help,
        value = function() return opts.format:format(Settings[key]) end,
        change = function(dir)
            local value = Settings[key]
            if opts.factor then
                value = dir > 0 and value * opts.factor or value / opts.factor
            else
                -- Recale sur un multiple du pas (une valeur memorisee peut tomber entre deux crans).
                value = math.floor((value + dir * opts.step) / opts.step + 0.5) * opts.step
            end
            Settings[key] = Clamp(value, opts.min, opts.max)
        end,
    }
end

-- Marque un reglage comme dependant de "Modifs graphiques" (grise quand c'est coupe).
local function graphic(item)
    item.graphic = true
    return item
end

local items = {
    toggleItem('Modifs graphiques', 'graphics',
        'Active ou coupe d\'un coup le ciel propre, les nuages, le grand soleil et les distances d\'affichage.'),
    toggleItem('Caméra smooth', 'smooth',
        'Adoucit la rotation et les déplacements.'),
    numberItem('Smooth : rotation', 'smoothRotation',
        'Réactivité de la rotation en mode smooth. Plus petit = plus flottant.',
        { format = '%.2f', step = 0.25, min = 0.5, max = 15.0 }),
    numberItem('Smooth : déplacement', 'smoothMovement',
        'Réactivité des déplacements en mode smooth. Plus petit = plus flottant.',
        { format = '%.2f', step = 0.25, min = 0.5, max = 15.0 }),
    toggleItem('Verrouillage vertical', 'verticalLock',
        'La hauteur ne change plus quand tu avances (touche H).'),
    numberItem('Vitesse', 'speed',
        'Vitesse de vol (aussi à la molette).',
        { format = '%.1f m/s', factor = Config.Speed.Step, min = Config.Speed.Min, max = Config.Speed.Max }),
    numberItem('FOV (zoom)', 'fov',
        'Angle de vue. Plus petit = plus zoomé.',
        { format = '%.0f', step = 1.0, min = 5.0, max = 120.0 }),
    numberItem('Sensibilité souris', 'sensitivity',
        'Vitesse de rotation de la caméra.',
        { format = '%.2f', step = 0.25, min = 0.5, max = 20.0 }),
    graphic(numberItem('Ciel propre', 'skyIntensity',
        'Suppression de la brume. 0 % = brume normale du jeu, 100 % = image nette même de très loin.',
        { format = '%.0f %%', step = 5.0, min = 0.0, max = 100.0 })),
    graphic(numberItem('Nuages', 'clouds',
        'Opacité des nuages. 0 % = aucun nuage, 100 % = nuages normaux.',
        { format = '%.0f %%', step = 5.0, min = 0.0, max = 100.0 })),
    graphic(toggleItem('Forcer le grand soleil', 'forceSunny',
        'Météo dégagée et sans pluie, quelle que soit celle du serveur.')),
    graphic(numberItem('Distance d\'affichage', 'lodScale',
        'Décor, véhicules et piétons restent détaillés de plus loin. x1 = normal. Plus haut = plus lourd pour le PC.',
        { format = 'x%.0f', step = 1.0, min = 1.0, max = 15.0 })),
    graphic(numberItem('Distance des ombres', 'shadowScale',
        'Les ombres portent plus loin, mais deviennent moins nettes en montant. x1 = normal.',
        { format = 'x%.1f', step = 0.5, min = 1.0, max = 10.0 })),
    toggleItem('Cacher mon perso', 'hidePed',
        'Ton perso est invisible sur ton écran seulement.'),
    toggleItem('Texte de confirmation', 'showFeedback',
        'Petit texte en bas quand tu changes la vitesse ou le lock.'),
    {
        label = 'Réinitialiser',
        help = 'Remet tous les réglages par défaut (config.lua).',
        activate = ResetSettings,
    },
}

local function pressedWithRepeat(control)
    local now = GetGameTimer()
    if IsDisabledControlJustPressed(0, control) then
        repeatAt = now + 350
        return true
    end
    if IsDisabledControlPressed(0, control) and now >= repeatAt then
        repeatAt = now + 50
        return true
    end
    return false
end

local function drawText(text, x, y, scale, shade, alignRight)
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(shade, shade, shade, 255)
    if alignRight then
        SetTextRightJustify(true)
        SetTextWrap(0.0, x)
    else
        SetTextWrap(X, X + W - PAD)
    end
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

local function drawBox(y, height, shade, alpha)
    DrawRect(X + W / 2, y + height / 2, W, height, shade, shade, shade, alpha)
end

local function draw()
    local y = Y

    drawBox(y, TITLE_H, 20, 235)
    drawText('FREECAM B-ROLL', X + PAD, y + 0.008, 0.5, 255)
    y = y + TITLE_H

    for i = 1, #items do
        local item = items[i]
        local isSelected = i == selected
        local textShade = isSelected and 0 or 255
        if item.graphic and not Settings.graphics then
            textShade = isSelected and 140 or 110
        end

        if isSelected then
            drawBox(y, ROW_H, 240, 235)
        else
            drawBox(y, ROW_H, 0, 170)
        end

        drawText(item.label, X + PAD, y + 0.004, 0.33, textShade)
        if item.value then
            drawText(item.value(), X + W - PAD, y + 0.004, 0.33, textShade, true)
        end
        y = y + ROW_H
    end

    drawBox(y, HELP_H, 20, 235)
    drawText(items[selected].help, X + PAD, y + 0.005, 0.28, 210)
    y = y + HELP_H

    drawBox(y, FOOTER_H, 0, 200)
    drawText('Flèches : choisir / régler   -   Entrée : valider   -   G : fermer', X + PAD, y + 0.004, 0.26, 170)
end

function Menu.close()
    if not Menu.open then return end
    Menu.open = false
    SaveSettings()
end

function Menu.toggle()
    if Menu.open then
        Menu.close()
    else
        Menu.open = true
    end
end

-- A appeler a chaque image, controles deja desactives.
function Menu.update()
    if not Menu.open then return end

    local item = items[selected]
    if pressedWithRepeat(CTRL_UP) then
        selected = selected > 1 and selected - 1 or #items
    elseif pressedWithRepeat(CTRL_DOWN) then
        selected = selected < #items and selected + 1 or 1
    elseif item.change and pressedWithRepeat(CTRL_LEFT) then
        item.change(-1)
    elseif item.change and pressedWithRepeat(CTRL_RIGHT) then
        item.change(1)
    elseif item.activate and IsDisabledControlJustPressed(0, CTRL_ACCEPT) then
        item.activate()
    elseif IsDisabledControlJustPressed(0, CTRL_BACK) then
        Menu.close()
        return
    end

    draw()
end
