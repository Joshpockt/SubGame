extends Station



func _get_player_input():
	var throttle_input = Input.get_axis("move_backward","move_forward")
	var steering_input = Input.get_axis("move_left","move_right")
	var vertical_input = Input.get_axis("move_down", "move_up")
	
	SubExterior.throttle_input = throttle_input
	SubExterior.steering_input = steering_input
	SubExterior.vertical_input = vertical_input


@rpc("authority", "call_local", "reliable")
func update_current_controller_id(peer_id: int):
	if peer_id == -1:
		current_controller_id = -1
		SubExterior.exterior_instance.set_multiplayer_authority(1)
		return
	current_controller_id = peer_id
	Networking.players[peer_id].set_player_controling(self)
	SubExterior.exterior_instance.set_multiplayer_authority(peer_id)
