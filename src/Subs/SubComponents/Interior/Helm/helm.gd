extends Node3D
class_name Helm

@export var interaction_box : InteractionBox3D
@export var player_anchor : Marker3D
@export var camera_anchor : Marker3D
var current_controller_id := 0


func _ready() -> void:
	var f := attempt_change_controller.bind(1)
	interaction_box.interacted.connect(f)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and NetworkUtilitys.is_id_mine(current_controller_id):
		attempt_change_controller(0)
		
		var player : Player = NetworkUtilitys.players[current_controller_id]
		
		player.tabout = false
		player.external_camera_hook = null


func attempt_change_controller(id: int) -> void:
	change_controller.rpc_id(1, id)
	if id == 0 and NetworkUtilitys.is_id_mine(current_controller_id):
		var player : Player = NetworkUtilitys.players[current_controller_id]
		print("exit")
		player.external_camera_hook = null
		player.tabout = false
		player.updateTabout()


@rpc("any_peer", "call_local", "reliable")
func change_controller(id: int) -> void:
	if NetworkUtilitys.is_host():
		controller_changed.rpc(id)


@rpc("authority", "call_local", "reliable")
func controller_changed(id: int) -> void:
	if id == 0 and NetworkUtilitys.is_id_mine(current_controller_id):
		return
	current_controller_id = id
	
	var player : Player = NetworkUtilitys.players[id]
	if id == multiplayer.get_unique_id():
		player.external_camera_hook = camera_anchor
		player.tabout = true
