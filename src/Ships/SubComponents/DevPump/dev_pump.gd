extends Node3D

@export_custom(PROPERTY_HINT_NONE,"suffix:m^3/s") var pump_speed := 1
@export var compartment : Compartment

func _physics_process(delta: float) -> void:
	if compartment:
		compartment.remove_water(pump_speed * delta)
