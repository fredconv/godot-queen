class_name TableServiceAccess
extends RefCounted
## Accès typé aux autoloads depuis la table (évite les erreurs d'analyse sur
## les identifiants globaux dans certains contextes de compilation).

const AudioServiceScript = preload("res://scripts/services/audio_service.gd")
const GameSessionScript = preload("res://scripts/services/game_session.gd")
const DebugServiceScript = preload("res://scripts/services/debug_service.gd")


static func audio(host: Node) -> Node:
	return host.get_node("/root/AudioService") as AudioServiceScript


static func session(host: Node) -> Node:
	return host.get_node("/root/GameSession") as GameSessionScript


static func debug(host: Node) -> Node:
	return host.get_node("/root/DebugService") as DebugServiceScript
