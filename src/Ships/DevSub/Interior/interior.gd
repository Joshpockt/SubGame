extends Node
class_name SubInterior

const PLAYER = preload("uid://1vhx3e3e0f80")

static var interior_instance : SubInterior

@export var max_fuel_seconds := 180.0

var fuel := 0.0:
	set(value):
		fuel = clamp(value, 0, max_fuel_seconds)

var fuel_uniform := 0.0:
	get():
		return fuel / max_fuel_seconds

@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner


func _ready() -> void:
	interior_instance = self
	fuel = max_fuel_seconds
	player_spawner.spawn_function = spawn_function
	player_spawner.spawned.connect(_on_player_spawned)
	
	if !is_multiplayer_authority(): return
	spawn_player(multiplayer.get_unique_id())
	for peer in multiplayer.get_peers():
		spawn_player(peer)


func _physics_process(delta: float) -> void:
	fuel = fuel - delta
	if Input.is_action_just_pressed("ui_up"):
		print(fuel)
	#print(fuel)
	#print(fuel_uniform)
	#print(fuel / max_fuel_seconds)


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
