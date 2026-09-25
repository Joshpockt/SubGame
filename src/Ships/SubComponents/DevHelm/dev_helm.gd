extends Station



func _get_player_input():
	var throttle_input = Input.get_axis("move_backward","move_forward")
	var steering_input = Input.get_axis("move_left","move_right")
	
	SubExterior.throttle_input = throttle_input
	SubExterior.steering_input = steering_input
