extends Node3D

@onready var collsision_point_sampler_3d: CollisionPointSampler = $Player/CameraPivot/CollsisionPointSampler3D

var t := 0.0
func _physics_process(delta: float) -> void:
	if collsision_point_sampler_3d.get_overlapping_areas().size() > 0:
		print("swag")
	
	
	t += delta
	$Compartment.add_water(1.0 * delta)
