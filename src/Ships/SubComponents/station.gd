extends Node3D
class_name Station

@onready var interaction_area: InteractionArea = $InteractionArea
@export var player_standing_marker : Marker3D
@export var camera_marker : Marker3D

var current_controller_id : int = -1

func _ready() -> void:
	interaction_area.interacted.connect(func(player): _interacted(player))

func _process(_delta: float) -> void:
	
	# If current controller is client
	if current_controller_id == multiplayer.get_unique_id():
		_get_player_input()
		if Input.is_action_just_pressed("cancel"):
			Networking.players[current_controller_id].set_player_controling(null)
			request_set_controller(-1)


func _interacted(peer_id: int):
	request_set_controller(peer_id)


func request_set_controller(peer_id: int):
	rpc_id(1,"control", peer_id)


@rpc("authority", "call_local", "reliable")
func update_current_controller_id(peer_id: int):
	current_controller_id = peer_id
	_on_controller_update(peer_id)
	
	if peer_id == -1: return
	if multiplayer.get_unique_id() == peer_id:
		Player.get_player(peer_id).set_player_controling(self)


@warning_ignore("unused_parameter")
func _on_controller_update(peer_id: int):
	pass


@rpc("any_peer","call_local","reliable")
func control(peer_id: int):
	#print_weewee()
	#print(!multiplayer.is_server())
	if !multiplayer.is_server(): return
	
	# If no one is using the station
	if current_controller_id == -1:
		current_controller_id = peer_id
		rpc("update_current_controller_id", peer_id)
	# If someone is trying to exit the station
	elif peer_id == -1:
		# Check if that person is currently using the station
		if multiplayer.get_remote_sender_id() == current_controller_id:
			rpc("update_current_controller_id", -1)


func _get_player_input():
	pass
