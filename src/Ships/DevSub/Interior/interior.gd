extends Node
class_name SubInterior

const PLAYER = preload("uid://1vhx3e3e0f80")
const HULL_BREACH = preload("uid://br5o4ec5ie751")

static var interior_instance : SubInterior

@export var max_fuel_seconds := 180.0

var fuel := 0.0:
	set(value):
		fuel = clamp(value, 0, max_fuel_seconds)

var fuel_uniform := 0.0:
	get():
		return fuel / max_fuel_seconds


@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner
@onready var ray_cast_3d: RayCast3D = $RayCast3D


func _ready() -> void:
	SubExterior.exterior_instance.sub_hit.connect(spawn_damage)
	
	interior_instance = self
	fuel = max_fuel_seconds
	player_spawner.spawn_function = spawn_function
	player_spawner.spawned.connect(_on_player_spawned)
	
	if !is_multiplayer_authority(): return
	spawn_player(multiplayer.get_unique_id())
	for peer in multiplayer.get_peers():
		spawn_player(peer)
	
	#var ammount := 16
	#for z in ammount:
		#for x in ammount:
			#for y in ammount:
				#var x_rot = ((TAU / ammount) * x) - PI
				#var y_rot = ((TAU / ammount) * y) - PI
				#var z_rot = ((TAU / ammount) * z) - PI
				#spawn_damage(Vector3(x_rot,y_rot,z_rot).normalized(), 1)
				#await get_tree().process_frame
	#for i in 10000:
		#var dir = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
		#spawn_damage(dir,1)
		#await get_tree().process_frame


func _physics_process(delta: float) -> void:
	fuel = fuel - delta
	if Input.is_action_just_pressed("ui_up"):
		print(fuel)
	#print(fuel)
	#print(fuel_uniform)
	#print(fuel / max_fuel_seconds)

func spawn_damage(direction: Vector3, str) -> void:
	if direction == Vector3.ZERO:
		return
	
	# Limit damage to the middle
	#direction.y = randf_range(-0.1, 0.1)
	direction.y = 0.0
	
	ray_cast_3d.position = direction * 50
	ray_cast_3d.position.y = randf_range(-0.5, 1)
	ray_cast_3d.target_position = -ray_cast_3d.position
	ray_cast_3d.target_position.y = 0.0
	ray_cast_3d.force_raycast_update()
	if !ray_cast_3d.is_colliding():
		return
	#assert(ray_cast_3d.is_colliding(), "Raycast should be colliding")
	
	var hull_breach_instance = HULL_BREACH.instantiate()
	add_child(hull_breach_instance)
	hull_breach_instance.position = ray_cast_3d.get_collision_point()
	#hull_breach_instance.position.y = clamp(hull_breach_instance.position.y, -1, 2)

func add_fuel(ammount: float) -> void:
	_sync_fuel_add.rpc(ammount)

@rpc("any_peer", "call_local", "reliable")
func _sync_fuel_add(fuel_added: float):
	fuel += fuel_added

@rpc("authority", "call_remote", "reliable")
func _sync_fuel_set(fuel_set: float):
	fuel = fuel_set

# NOTE: Only called on peers
func _on_player_spawned(player: Player) -> void:
	Networking.players[int(player.name)] = player


# NOTE: Only called on server
func spawn_player(id) -> void:
	var player = player_spawner.spawn(id)
	Networking.players[id] = player


func spawn_function(id: int) -> Node:
	var player_instance : Node3D = PLAYER.instantiate()
	player_instance.set_multiplayer_authority(id)
	player_instance.name = str(id)
	player_instance.position.y = -1
	return player_instance
