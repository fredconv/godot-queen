class_name OnlineRegistryConfig
extends Resource
## Configuration du registre de parties en ligne (Supabase PostgREST).


const DEFAULT_RESOURCE_PATH: String = "res://resources/data/online_registry_config.tres"

@export var supabase_url: String = ""
@export var supabase_anon_key: String = ""
@export var table_name: String = "public_lobbies"
@export var heartbeat_interval_sec: float = 15.0
@export var lobby_max_age_sec: float = 45.0


static func load_default() -> OnlineRegistryConfig:
	var resource: Resource = load(DEFAULT_RESOURCE_PATH)
	if resource is OnlineRegistryConfig:
		return resource as OnlineRegistryConfig
	return OnlineRegistryConfig.new()


func is_configured() -> bool:
	return not supabase_url.strip_edges().is_empty() and not supabase_anon_key.strip_edges().is_empty()


func get_rest_url() -> String:
	var base_url: String = supabase_url.strip_edges().trim_suffix("/")
	return "%s/rest/v1/%s" % [base_url, table_name.strip_edges()]
