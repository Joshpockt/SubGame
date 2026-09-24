extends Node
class_name SubInterior

@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner
const PLAYER = preload("uid://1vhx3e3e0f80")

static var interior_instance : SubInterior


func _ready() -> void:
	interior_instance = self
	player_spawner.spawn_function = spawn_function
	player_spawner.spawned.connect(_on_player_spawned)
	
	if !is_multiplayer_authority(): return
	spawn_player(multiplayer.get_unique_id())
	for peer in multiplayer.get_peers():
		spawn_player(peer)


# NOTE: Only called on peers
func _on_player_spawned(player: Player) -> void:
	Networking.players[int(player.name)] = player


# NOTE: Only called on server
func spawn_player(id) -> void:
	var player = player_spawner.spawn(id)
	Networking.players[id] = player


func spawn_function(id: int) -> Node:
	var player_instance = PLAYER.instantiate()
	player_instance.set_multiplayer_authority(id)
	player_instance.name = str(id)
	return player_instance
