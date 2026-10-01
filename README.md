# Freecam Editor

Freecam sans HUD pour tourner des B-rolls sur FiveM : caméra libre qui traverse les murs,
mode smooth, verrouillage vertical, ciel propre et distance d'affichage étendue, le tout
réglable en jeu depuis un menu.

Ressource autonome, sans framework (ni ESX ni QBCore requis).

## Installation

1. Télécharge ce dépôt et place le dossier dans `resources` sous le nom `broll_freecam`
   (ou un autre nom sans espace) :
   ```
   git clone https://github.com/StundZow/Freecam-Editor.git broll_freecam
   ```
2. Ajoute dans `server.cfg` :
   ```
   ensure broll_freecam
   ```
3. Redémarre le serveur (ou `refresh` puis `ensure broll_freecam` dans la console).

Par défaut, tous les joueurs peuvent utiliser la freecam. Sur un serveur public, réserve-la
avec une permission ACE : voir `Config.AcePermission` dans `config.lua`.

## Touches

| Touche | Action |
| --- | --- |
| `F11` ou `/freecam` | Activer / désactiver la freecam |
| Souris | Regarder |
| Avancer / reculer / gauche / droite | Se déplacer dans la direction du regard (haut/bas compris) |
| Molette | Régler la vitesse |
| `Shift` | Boost de vitesse tant que la touche est maintenue |
| `E` ou `Espace` | Monter à la verticale |
| `A` ou `Ctrl` | Descendre à la verticale |
| `G` | Ouvrir / fermer le menu de réglages |
| `H` | Verrouillage vertical : la caméra tourne librement mais reste à la même hauteur |

`F11`, `G` et `H` se changent en jeu : Échap > Paramètres > Raccourcis clavier > FiveM.
Un raccourci direct pour le smooth existe aussi dans cette liste, sans touche par défaut.

## Menu de réglages (`G`)

Flèches haut/bas pour choisir, gauche/droite pour régler, Entrée pour valider,
`G` ou Retour arrière pour fermer. La caméra reste pilotable pendant que le menu est
ouvert, donc les changements se voient en direct.

- Modifs graphiques : active ou coupe d'un coup le ciel propre, les nuages, le grand soleil
  et les distances d'affichage (leurs valeurs sont conservées)
- Caméra smooth, et sa réactivité (rotation / déplacement)
- Verrouillage vertical
- Vitesse
- FOV (zoom)
- Sensibilité souris
- Ciel propre : intensité de la suppression de la brume, de 0 à 100 %
- Nuages : opacité de 0 % (aucun) à 100 % (normaux)
- Forcer le grand soleil : météo dégagée et sans pluie, quelle que soit celle du serveur
- Distance d'affichage : de x1 (normal) à x15, pour garder le décor, les véhicules et les
  piétons détaillés de plus loin
- Distance des ombres : de x1 (normal) à x10 ; les ombres portent plus loin mais deviennent
  moins nettes en montant
- Cacher mon perso
- Texte de confirmation
- Réinitialiser

Les réglages sont mémorisés d'une session à l'autre. `config.lua` ne contient que
les valeurs de départ (celles que « Réinitialiser » remet).
