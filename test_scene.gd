extends Node3D
#
@onready var compartment: Compartment = $CompartmentManager/Compartment


var t := 0.0
func _process(delta: float) -> void:
	t += delta
	if t > 6.5: return
	#compartment.add_water(1.0 * delta)
