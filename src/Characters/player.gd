extends CharacterBody3D
class_name Player

@export var current_item : Item

var mouse_motion := Vector2.ZERO
var can_move := true

@onready var camera_3d: Camera3D = $CameraPivot/Camera3D
@onready var ray_cast_3d: RayCast3D = $CameraPivot/RayCast3D
@onready var camera_pivot: Node3D = $CameraPivot

static func get_player(peer_id: int) -> Player:
	return Networking.players[peer_id]

func _ready() -> void:
	if is_multiplayer_authority():
		camera_3d.current = true
		$CameraPivot/MeshInstance3D.hide()
		$MeshInstance3D.hide()


func _process(delta: float) -> void:
	if current_item:
		$Label3D.text = "item: " + current_item.name
	else:
		$Label3D.text = "item: None"


func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority(): return
	
	if Input.is_action_just_pressed("interact"):
		var area = ray_cast_3d.get_collider()
		if area is InteractionArea:
			area.inteact(multiplayer.get_unique_id())
	
	var direction := Vector3(
		Input.get_axis("move_left", "move_right"),
		0,
		Input.get_axis("move_forward","move_backward")
	).normalized().rotated(Vector3.UP, camera_pivot.rotation.y)
	
	velocity = direction * 5.0
	if can_move: move_and_slide()
	else: velocity = Vector3.ZERO
	
	if can_move:
		mouse_motion *= 0.0015
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x + mouse_motion.y, -PI/2, PI/2)
		camera_pivot.rotation.y = wrap(camera_pivot.rotation.y + mouse_motion.x, -PI, PI)
	mouse_motion = Vector2.ZERO


func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			mouse_motion -= event.screen_relative


func give_item(item: Item) -> void:
	if current_item == null:
		current_item = item
		_sync_item.rpc(current_item.get_uid())

func remove_item() -> void:
	current_item = null
	_sync_item.rpc("")

@rpc("any_peer", "call_remote", "reliable")
func _sync_item(item_uid: String):
	if item_uid == "":
		current_item = null
	else:
		current_item = load(item_uid)


func set_player_controling(station: Station):
	if station == null:
		can_move = true
		camera_3d.top_level = false
		camera_3d.position = Vector3.ZERO
		camera_3d.rotation = Vector3.ZERO
	else:
		can_move = false
		global_position = station.player_standing_marker.global_position
		camera_3d.top_level = true
		camera_3d.global_position = station.camera_marker.global_position
		camera_3d.global_rotation = station.camera_marker.global_rotation
		camera_pivot.rotation.y = station.camera_marker.global_rotation.y
		camera_pivot.rotation.x = station.camera_marker.global_rotation.x
