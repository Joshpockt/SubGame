extends RigidBody3D
class_name Torpedo

@export var target : Node3D
#@export var yaw_pid : PID
#@export var pitch_pid : PID
#@export var roll_pid : PID
#@export var target_pid : PID


#func _physics_process(delta: float) -> void:
	#var global_direction = global_position.direction_to(target.global_position)
	


var speed: float = 1.0

func look_follow(state: PhysicsDirectBodyState3D, current_transform: Transform3D, target_position: Vector3) -> void:
	#state.angular_velocity = Vector3.UP
	var forward_local_axis: Vector3 = Vector3(0, 0, -1)
	var forward_dir: Vector3 = (current_transform.basis * forward_local_axis).normalized()
	var target_dir: Vector3 = (target_position - current_transform.origin).normalized()
	#var local_speed: float = clampf(speed, 0, acos(forward_dir.dot(target_dir)))
	
	
	var damp = (-global_basis.z.cross(target_dir).normalized() * angular_velocity).length() * 1.5
	
	state.apply_torque(clamp((speed) - damp, 0.0, sqrt(linear_velocity.length()) * 0.3) * forward_dir.cross(target_dir).normalized())


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if target:
		var target_position = target.global_position
		look_follow(state, global_transform, target_position)
	apply_central_force(-global_basis.z * 32)


#func _physics_process(delta: float) -> void:
	#if target:
		#var local_pos = to_local(target.global_position)#(target.global_position - global_position).rotated(Vector3.RIGHT, -rotation.x).rotated(Vector3.UP, -rotation.y)
		#var yaw_error = atan2(local_pos.x, -local_pos.z)
		#var pitch_error = atan2(local_pos.y, -local_pos.z)
		#
		#var yaw_force = clamp(yaw_pid.compute(yaw_error, 0.0, delta), -1, 1)
		#var pitch_force = clamp(pitch_pid.compute(-pitch_error, 0.0, delta), -1, 1)
		#var roll_force = clamp(roll_pid.compute(rotation.z, 0.0, delta), -1 , 1)
		#
		##var pitch_force = Input.get_axis("move_backward", "move_forward")
		##var yaw_force = Input.get_axis("move_left", "move_right")
		#
		#apply_torque(to_global(Vector3.UP * yaw_force) - global_position)
		#apply_torque(to_global(Vector3.RIGHT * pitch_force) - global_position)
		##apply_torque(Vector3.FORWARD * roll_force)


#class_name Torpedo
#
#@export var target : Node3D
#@export var target_pid : PID
#@export var roll_pid : PID
#
#func _process(delta: float) -> void:
	#if target:
		#var current_direction = -global_transform.basis.z
		#var desired_direction = global_position.direction_to(target.global_position)
		#var axis = current_direction.cross(desired_direction)
		##var direction_difference = (current_direction - desired_direction).length()
		#
		#var angle = acos(current_direction.dot(desired_direction))
		##print(angle)
		##var force = clamp(angle * 0.1, -1 , 1)
		#var angle_force = clamp(target_pid.compute(-angle, 0.0, delta), -1 , 1)
		#
		#var roll_force = clamp(roll_pid.compute(rotation.z, 0.0, delta), -1 , 1)
		#
		#apply_torque(axis.normalized() * angle_force)
		#apply_torque(global_basis.z * roll_force)
