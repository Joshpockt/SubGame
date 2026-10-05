extends RigidBody3D
class_name Torpedo

const EXPLOSION = preload("uid://b28khgabl81gf")
@export var target : Node3D


func look_follow(state: PhysicsDirectBodyState3D, current_transform: Transform3D, target_position: Vector3) -> void:
	#state.angular_velocity = Vector3.UP
	var forward_local_axis: Vector3 = Vector3(0, 0, -1)
	var forward_dir: Vector3 = (current_transform.basis * forward_local_axis).normalized()
	var target_dir: Vector3 = (target_position - current_transform.origin).normalized()
	#var local_speed: float = clampf(speed, 0, acos(forward_dir.dot(target_dir)))
	
	var damp = (-global_basis.z.cross(target_dir).normalized() * angular_velocity).length() * 0.4
	
	state.apply_torque(clamp((2.0) - damp, 0.0, sqrt(linear_velocity.length()) * 0.4) * forward_dir.cross(target_dir).normalized())

var last_position := Vector3.ZERO
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if target:
		var est_tof := global_position.distance_to(target.global_position) / linear_velocity.length()
		var target_velocity = (target.global_position - last_position) / state.step
		#print(target_velocity)
		last_position = target.global_position
		var target_position = target.global_position + (target_velocity * est_tof)
		#print(target_position)
		#var target_position = target.global_position
		look_follow(state, global_transform, target_position)
	apply_central_force(-global_basis.z * 32)
	
	if state.get_contact_count() > 0:
		var explosion_instance : Explosion = EXPLOSION.instantiate()
		add_sibling(explosion_instance)
		explosion_instance.global_position = global_position
		queue_free()
