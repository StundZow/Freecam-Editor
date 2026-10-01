Config = {}

-- Ce fichier donne les valeurs DE DEPART. En jeu, tout se regle dans le menu (touche G)
-- et tes reglages sont memorises : pour revenir aux valeurs d'ici, utilise
-- "Reinitialiser" dans le menu.

-- Touches par defaut. Une fois le script lance une premiere fois, elles se
-- changent en jeu : Echap > Parametres > Raccourcis clavier > FiveM.
Config.Keys = {
    Toggle       = 'F11', -- activer / desactiver la freecam (ou commande /freecam)
    Menu         = 'G',   -- menu de reglages
    VerticalLock = 'H',   -- verrouillage de la hauteur
}

Config.Speed = {
    Default = 8.0,   -- vitesse de depart (m/s)
    Min     = 0.2,
    Max     = 300.0,
    Step    = 1.25,  -- multiplicateur par cran de molette
    Boost   = 3.0,   -- multiplicateur quand Shift est maintenu
}

-- Sensibilite de la souris
Config.Sensitivity = 5.0

-- Reactivite en mode smooth : plus la valeur est petite, plus c'est "flottant".
Config.Smooth = {
    Rotation = 2.5,
    Movement = 2.0,
}

-- Angle de vue de la camera (plus petit = plus zoome)
Config.Fov = 50.0

-- Interrupteur general des modifs graphiques (ciel propre, nuages, grand soleil,
-- distance d'affichage, distance des ombres). Sur false, l'image reste celle du jeu, sans rien toucher
-- aux reglages ci-dessous.
Config.Graphics = true

-- Ciel propre, pour une image nette meme de tres loin (uniquement sur ton ecran).
Config.Sky = {
    Intensity  = 100.0, -- suppression de la brume, en % : 0 = brume normale du jeu, 100 = aucune brume
    Clouds     = 0.0,   -- opacite des nuages, en % : 0 = aucun nuage, 100 = nuages normaux
    ForceSunny = true,  -- meteo degagee et sans pluie, quelle que soit celle du serveur
}

-- Distance d'affichage : multiplie la distance a laquelle le jeu garde les versions
-- detaillees du decor, des vehicules et des pietons. 1.0 = normal (rien n'est modifie).
-- Plus haut = plus lourd.
Config.LodScale = 1.0

-- Distance des ombres : multiplie la portee des ombres. 1.0 = normal.
-- Plus haut = ombres visibles de plus loin, mais moins nettes.
Config.ShadowScale = 1.0

-- Cache ton personnage (uniquement sur ton ecran, les autres joueurs le voient toujours).
-- Mets false si tu veux filmer ton propre perso.
Config.HidePed = true

-- Petit texte affiche ~1 seconde quand tu changes la vitesse / le lock.
-- Mets false pour n'avoir strictement rien a l'ecran.
Config.ShowFeedback = true

-- false = tout le monde peut utiliser la freecam.
-- Sinon, nom d'une permission ACE, ex: 'broll.freecam', a donner dans server.cfg :
--   add_ace group.admin broll.freecam allow
Config.AcePermission = false
