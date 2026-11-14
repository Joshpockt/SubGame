extends Node3D

@onready var compartment: Compartment = $Compartment

func _process(delta: float) -> void:
	compartment.add_water(0.5 * delta)
