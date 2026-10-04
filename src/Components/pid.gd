extends Resource
class_name PID

@export var p_gain := 0.0
@export var d_gain := 0.0
@export var use_velocity := false

var last_error := 0.0

func compute(process_variable : float, set_point : float, delta : float, velocity : float = 0.0) -> float:
	var error = set_point - process_variable
	
	var p = error * p_gain
	
	
	var error_change := 0.0
	if use_velocity:
		error_change = velocity
	else:
		error_change = (error - last_error) / delta
	
	var d = error_change * d_gain
	
	last_error = error
	return p + d
