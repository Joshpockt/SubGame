extends RigidBody3D

var target : Node3D

@onready var ray_cast_3d: RayCast3D = $RayCast3D


func _physics_process(delta: float) -> void:
	target = SubExterior.exterior_instance
	#var sub_pos := SubExterior.exterior_instance.global_position
	#ray_cast_3d.target_position = to_local(sub_pos)
	#if ray_cast_3d.get_collider() is SubExterior:
		##print(target)
		#target = ray_cast_3d.get_collider()
	#else:
		#target = null
	if target:
		var dir = target.global_position - global_position
		apply_central_force(dir * 2.5)
