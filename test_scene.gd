extends Node3D
#
@onready var compartment: Compartment = $CompartmentManager/Compartment

var fill_speed := 1.0

var b := false
var t := 0.0
func _process(delta: float) -> void:
	t += delta
	if t > 5.0: b = true
	#if compartment.fill_level == 1.0:
		#b = true
	
	if b == true:
		compartment.remove_water(fill_speed * delta)
		return
	compartment.add_water(fill_speed * delta)
