extends Station

@export var sub_exterior : SubExterior

func _get_player_input():
	var throttle_input = Input.get_axis("move_backward","move_forward")
	var steering_input = Input.get_axis("move_left","move_right")
	var vertical_input = Input.get_axis("move_down", "move_up")
	
	sub_exterior.throttle_input = throttle_input
	sub_exterior.steering_input = steering_input
	sub_exterior.vertical_input = vertical_input
	
	if Input.is_action_just_pressed("shoot"):
		if $"../DevTorpedoController":
			$"../DevTorpedoController".shoot()

func _on_controller_update(peer_id: int):
	sub_exterior.set_multiplayer_authority(peer_id)
	if peer_id == -1:
		sub_exterior.throttle_input = 0.0
		sub_exterior.steering_input = 0.0
		sub_exterior.vertical_input = 0.0

#@rpc("authority", "call_local", "reliable")
#func update_current_controller_id(peer_id: int):
	#if peer_id == -1:
		#current_controller_id = -1
		#SubExterior.exterior_instance.set_multiplayer_authority(1)
		#return
	#current_controller_id = peer_id
	#Networking.players[peer_id].set_player_controling(self)
	#SubExterior.exterior_instance.set_multiplayer_authority(peer_id)
