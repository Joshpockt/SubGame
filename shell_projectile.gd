extends Node3D

const EXPLOSION = preload("uid://b28khgabl81gf")

@onready var ray_cast_3d: RayCast3D = $RayCast3D

func _ready() -> void:
	await get_tree().physics_frame
	ray_cast_3d.force_raycast_update()
	if ray_cast_3d.is_colliding():
		print("spink")
		var explosion_instance : Explosion = EXPLOSION.instantiate()
		explosion_instance.position = ray_cast_3d.get_collision_point()
		#explosion_instance.explosion_strength = 1000.0
		add_sibling(explosion_instance)
		queue_free()
