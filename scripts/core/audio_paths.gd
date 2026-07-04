class_name AudioPaths
## Chemins des fichiers audio du jeu, mappés par événement logique.
## Point de vérité unique : `AudioService` s'appuie sur ces constantes, aucun
## autre script ne doit coder un chemin `res://assets/audio/...` en dur.
##
## Mapping événement -> fichier (voir docs/DECISIONS.md ADR-010) :
## - DEAL_SINGLE_CARD : une carte distribuée individuellement (séquence de
##   distribution carte par carte).
## - DEAL_BURST       : plusieurs cartes distribuées/déplacées d'un coup.
##   Réutilisé pour le ramassage du pli (TRICK_COLLECT) : mouvement similaire
##   de plusieurs cartes, aucun asset dédié au ramassage n'a été fourni.
## - CARD_PLAYED      : une carte posée sur la table (jouée dans le pli).
## - CARD_PLAYED_ALT  : variante du son de pose. Réutilisée pour le survol
##   (CARD_HOVER, à volume réduit) : aucun asset dédié au survol n'a été
##   fourni, cette variante "légère" convient mieux qu'un doublon du son
##   principal de pose.

const DEAL_SINGLE_CARD: String = "res://assets/audio/Card Dealing one card.wav"
const DEAL_BURST: String = "res://assets/audio/Card Dealing multiple.wav"
const CARD_PLAYED: String = "res://assets/audio/Card Playing launching one card.wav"
const CARD_PLAYED_ALT: String = "res://assets/audio/Card Playing launching one card alt.wav"

## Ramassage du pli après un pli résolu : réutilise DEAL_BURST (voir note ci-dessus).
const TRICK_COLLECT: String = DEAL_BURST
## Survol léger d'une carte : réutilise CARD_PLAYED_ALT à volume réduit (voir note ci-dessus).
const CARD_HOVER: String = CARD_PLAYED_ALT

## Tous les chemins à précharger au démarrage (dédupliqués par `AudioService`).
const ALL_PATHS: Array[String] = [
	DEAL_SINGLE_CARD,
	DEAL_BURST,
	CARD_PLAYED,
	CARD_PLAYED_ALT,
]

## Musiques d'ambiance de fond, jouées en playlist mélangée par `AudioService`
## (voir docs/DECISIONS.md ADR-013). Contrairement aux SFX ci-dessus, ces
## fichiers sont au format `.mp3` (musique longue, pas d'effet ponctuel).
const MUSIC_LANTERN_TABLE: String = "res://assets/audio/musics/Lantern Table.mp3"
const MUSIC_LANTERN_TABLE_ALT: String = "res://assets/audio/musics/Lantern Table_alt.mp3"
const MUSIC_MOSSY_SHUFFLE: String = "res://assets/audio/musics/Mossy Shuffle.mp3"
const MUSIC_MOSSY_SHUFFLE_ALT: String = "res://assets/audio/musics/Mossy Shuffle_alt.mp3"

## Playlist de musique d'ambiance (voir `AudioService.play_random()`/`play_next()`).
const MUSIC_TRACKS: Array[String] = [
	MUSIC_LANTERN_TABLE,
	MUSIC_LANTERN_TABLE_ALT,
	MUSIC_MOSSY_SHUFFLE,
	MUSIC_MOSSY_SHUFFLE_ALT,
]
