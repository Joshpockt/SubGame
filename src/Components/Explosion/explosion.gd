extends Node3D
class_name Explosion

const BASE_EXPLOSION_FORCE = 15

var explosion_strength := 100.0

@onready var area_3d: Area3D = $Area3D


func _physics_process(_delta: float) -> void:
	for body in area_3d.get_overlapping_bodies():
		if body is RigidBody3D:
			body.apply_central_impulse(
				global_position.direction_to(body.global_position) * explosion_strength * BASE_EXPLOSION_FORCE
				)
	queue_free()
	#process_mode = Node.PROCESS_MODE_DISABLED
