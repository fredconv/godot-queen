class_name NetworkMessages
extends RefCounted
## Identifiants stables des messages réseau (phases 7+).


const REQUEST_PLAY_CARD: StringName = &"request_play_card"
const SERVER_CARD_PLAYED: StringName = &"server_card_played"
const SERVER_SNAPSHOT: StringName = &"server_snapshot"
const SERVER_ERROR: StringName = &"server_error"
const REQUEST_PRIVATE_SNAPSHOT: StringName = &"request_private_snapshot"
const PEER_DISCONNECTED: StringName = &"peer_disconnected"
const PEER_RECONNECTED: StringName = &"peer_reconnected"
const SEAT_RECONNECT_COUNTDOWN: StringName = &"seat_reconnect_countdown"
const SEAT_REPLACED_BY_AI: StringName = &"seat_replaced_by_ai"
const REQUEST_RECONNECT: StringName = &"request_reconnect"
