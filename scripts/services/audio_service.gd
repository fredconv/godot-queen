extends Node
## AudioService (autoload)
## Centralise la lecture des effets sonores et de la musique. Les sons sont
## préchargés une fois (voir `AudioPaths`) puis joués via un petit pool de
## `AudioStreamPlayer`, ce qui permet à plusieurs sons courts de se chevaucher
## (ex. plusieurs cartes distribuées coup sur coup) sans se couper les uns les
## autres.
##
## Mapping événement -> fichier : voir `scripts/core/audio_paths.gd`.
##
## Découplage : ce service écoute directement les signaux `GameEvents`
## (`card_played`, `trick_resolved`) plutôt que d'exiger que chaque appelant
## (UI ou futur `MatchManager`) appelle explicitement une méthode de son.
## `MatchManager` n'a donc rien de spécial à faire pour l'audio de base : émettre
## les signaux `GameEvents` suffit. Les méthodes publiques (`play_card_played()`,
## `play_trick_collect()`, ...) restent disponibles pour les cas où un appel
## direct est plus simple (ex. démo UI sans `MatchManager`).

## Taille du pool de lecteurs SFX (sons courts qui se chevauchent peu).
const SFX_PLAYER_POOL_SIZE: int = 6
## Délai minimal (secondes) entre deux sons de survol, pour éviter le spam
## quand le pointeur traverse rapidement plusieurs cartes de la main.
const HOVER_COOLDOWN_SEC: float = 0.12
## Volume relatif (0-1, multiplié par le volume utilisateur) du son de survol :
## plus discret que les autres SFX puisqu'il se déclenche très fréquemment.
const HOVER_VOLUME_SCALE: float = 0.6

var _sfx_streams: Dictionary = {}
var _sfx_players: Array[AudioStreamPlayer] = []
var _next_player_index: int = 0
var _last_hover_time_msec: int = 0

## --- Musique d'ambiance (voir docs/DECISIONS.md ADR-013) ---
var _music_player: AudioStreamPlayer
var _music_streams: Dictionary = {}
## Ordre de lecture courant (mélangé), consommé séquentiellement puis
## re-mélangé une fois épuisé — voir `_play_track_at_playlist_pos()`.
var _music_playlist_order: Array[String] = []
var _music_playlist_pos: int = -1
var _current_music_path: String = ""

func _ready() -> void:
	_preload_streams()
	_build_player_pool()
	_preload_music()
	_build_music_player()
	GameEvents.card_played.connect(_on_card_played)
	GameEvents.trick_resolved.connect(_on_trick_resolved)
	ensure_music_playing()

## Démarre la musique si elle est activée et qu'aucune piste n'est déjà en
## cours de lecture. Idempotent (sans effet si la musique tourne déjà ou est
## désactivée) : appelée à la fois depuis `_ready()` (cas nominal, dès le
## lancement du moteur) et depuis le `_ready()` de la première scène affichée
## (`main_menu.gd`), en filet de sécurité. Ce second appel garantit que la
## musique démarre bien au plus tard à l'arrivée sur le menu, même dans le cas
## où `_ready()` d'un autoload s'exécute trop tôt dans l'initialisation du
## moteur pour que la lecture audio démarre de façon fiable (voir
## docs/DECISIONS.md ADR-013).
func ensure_music_playing() -> void:
	if not ConfigService.get_music_enabled():
		return
	if _music_player.playing:
		return
	play_random()

## --- API typée (préférer ces méthodes aux chaînes génériques `play_sfx`) ---

## Une carte distribuée individuellement (à appeler une fois par carte lors
## d'une séquence de distribution étalée dans le temps).
func play_deal_card() -> void:
	_play_stream(AudioPaths.DEAL_SINGLE_CARD)

## Plusieurs cartes distribuées/déplacées d'un coup (paquet complet).
func play_deal_burst() -> void:
	_play_stream(AudioPaths.DEAL_BURST)

## Survol léger d'une carte. Respecte un cooldown court pour éviter le spam
## quand le pointeur traverse rapidement plusieurs cartes.
func play_card_hover() -> void:
	var now_msec: int = Time.get_ticks_msec()
	if now_msec - _last_hover_time_msec < HOVER_COOLDOWN_SEC * 1000.0:
		return
	_last_hover_time_msec = now_msec
	_play_stream(AudioPaths.CARD_HOVER, HOVER_VOLUME_SCALE)

## Une carte posée sur la table (jouée dans le pli en cours).
func play_card_played() -> void:
	_play_stream(AudioPaths.CARD_PLAYED)

## Ramassage des 4 cartes du pli après résolution.
func play_trick_collect() -> void:
	_play_stream(AudioPaths.TRICK_COLLECT)

## Démarre la playlist de musique d'ambiance dans un ordre mélangé. Appelée
## automatiquement au lancement du jeu (voir `_ready()`) si la musique est
## activée ; peut aussi être appelée directement (ex. après réactivation sans
## piste déjà chargée).
func play_random() -> void:
	if AudioPaths.MUSIC_TRACKS.is_empty():
		return
	_music_playlist_order = AudioPaths.MUSIC_TRACKS.duplicate()
	_music_playlist_order.shuffle()
	_music_playlist_pos = 0
	_play_track_at_playlist_pos()

## Passe immédiatement à une piste différente de celle en cours (bouton
## "SUIVANT" de `TopMenuBar`). Re-pause aussitôt si la musique est désactivée,
## pour ne pas la réactiver silencieusement via ce bouton.
func play_next() -> void:
	if AudioPaths.MUSIC_TRACKS.size() <= 1:
		play_random()
	else:
		_music_playlist_pos += 1
		_play_track_at_playlist_pos()
	if not ConfigService.get_music_enabled():
		_music_player.stream_paused = true

func stop_music() -> void:
	_music_player.stop()

## Active/désactive la musique et persiste la préférence via `ConfigService`.
## Désactiver met en pause (reprise possible au même point) plutôt que
## d'arrêter, pour un comportement "mute" simple et prévisible.
func set_music_enabled(enabled: bool) -> void:
	ConfigService.set_music_enabled(enabled)
	if not enabled:
		_music_player.stream_paused = true
		return
	if _music_player.stream == null:
		play_random()
	else:
		_music_player.stream_paused = false

## Ancienne API générique : conservée pour compatibilité mais non mappée à un
## son. Préférer les méthodes typées ci-dessus pour tout nouvel appel.
func play_sfx(sfx_name: StringName) -> void:
	push_warning("AudioService.play_sfx: événement générique non mappé (%s)" % sfx_name)

## --- Détails internes ---

func _preload_streams() -> void:
	for path in AudioPaths.ALL_PATHS:
		var stream: AudioStream = load(path)
		if stream:
			_sfx_streams[path] = stream
		else:
			push_warning("AudioService: impossible de charger le son %s" % path)

func _build_player_pool() -> void:
	for _i in SFX_PLAYER_POOL_SIZE:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(player)
		_sfx_players.append(player)

func _play_stream(path: String, volume_scale: float = 1.0) -> void:
	var stream: AudioStream = _sfx_streams.get(path)
	if not stream:
		push_warning("AudioService: son non préchargé (%s)" % path)
		return
	var player: AudioStreamPlayer = _next_available_player()
	player.stream = stream
	player.volume_db = _volume_scale_to_db(volume_scale)
	player.play()

## Round-robin sur le pool : renvoie un lecteur libre s'il y en a un, sinon
## réutilise le suivant du pool (coupe le son le plus ancien plutôt que
## d'ignorer le nouveau — acceptable pour des SFX courts et peu nombreux).
func _next_available_player() -> AudioStreamPlayer:
	for player in _sfx_players:
		if not player.playing:
			return player
	var fallback_player: AudioStreamPlayer = _sfx_players[_next_player_index]
	_next_player_index = (_next_player_index + 1) % _sfx_players.size()
	return fallback_player

## Convertit un volume linéaire (0-1, volume utilisateur × facteur d'appel) en
## décibels pour `AudioStreamPlayer.volume_db`. Respecte `ConfigService` s'il
## expose un volume utilisateur.
func _volume_scale_to_db(volume_scale: float) -> float:
	var user_volume: float = ConfigService.get_volume()
	var linear: float = clampf(user_volume * volume_scale, 0.0, 1.0)
	if linear <= 0.0:
		return -80.0
	return linear_to_db(linear)

func _on_card_played(_player_id: int, _card: Variant) -> void:
	play_card_played()

func _on_trick_resolved(_winner_id: int, _points: int) -> void:
	play_trick_collect()

## --- Détails internes : musique d'ambiance ---

func _preload_music() -> void:
	for path in AudioPaths.MUSIC_TRACKS:
		var stream: AudioStream = load(path)
		if stream:
			_music_streams[path] = stream
		else:
			push_warning("AudioService: impossible de charger la musique %s" % path)

func _build_music_player() -> void:
	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)
	_music_player.finished.connect(_on_music_finished)

## Avance dans `_music_playlist_order` ; re-mélange et recommence une fois la
## playlist épuisée (boucle infinie de musique de fond). Si le mélange place
## par malchance la piste courante en tête, on l'échange avec la suivante pour
## garantir qu'on ne rejoue jamais deux fois la même piste d'affilée.
func _play_track_at_playlist_pos() -> void:
	if _music_playlist_pos >= _music_playlist_order.size():
		_music_playlist_order.shuffle()
		_music_playlist_pos = 0
		if _music_playlist_order.size() > 1 and _music_playlist_order[0] == _current_music_path:
			var tmp: String = _music_playlist_order[0]
			_music_playlist_order[0] = _music_playlist_order[1]
			_music_playlist_order[1] = tmp
	_play_track(_music_playlist_order[_music_playlist_pos])

func _play_track(path: String) -> void:
	var stream: AudioStream = _music_streams.get(path)
	if not stream:
		push_warning("AudioService: musique non préchargée (%s)" % path)
		return
	_current_music_path = path
	_music_player.stream = stream
	_music_player.volume_db = _music_volume_to_db()
	_music_player.stream_paused = false
	_music_player.play()

## Piste terminée : enchaîne automatiquement sur la suivante de la playlist
## mélangée, sauf si la musique a été désactivée entre-temps.
func _on_music_finished() -> void:
	if not ConfigService.get_music_enabled():
		return
	_music_playlist_pos += 1
	_play_track_at_playlist_pos()

## Convertit `ConfigService.get_music_volume()` (0-1) en décibels. Volume dédié
## à la musique (pas de facteur d'appel comme pour les SFX) : voir ADR-013
## pour le ratio musique/SFX par défaut.
func _music_volume_to_db() -> float:
	var linear: float = clampf(ConfigService.get_music_volume(), 0.0, 1.0)
	if linear <= 0.0:
		return -80.0
	return linear_to_db(linear)
