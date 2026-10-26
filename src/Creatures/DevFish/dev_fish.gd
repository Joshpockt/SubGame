extends RigidBody3D

var target : Node3D

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var sonar_emitter: SonarEmitter = $SonarEmitter


var synced_linear_velocity := Vector3.ZERO
var synced_angular_velocity := Vector3.ZERO
var has_synced := false

func _ready() -> void:
	sonar_emitter.volume = 15

func _physics_process(_delta: float) -> void:
	#target = SubExterior.exterior_instance
	if target:
		var dir = target.global_position - global_position
		apply_central_force(dir * 2.5)
	
	if is_multiplayer_authority():
		i += 1
		if i >= 5:
			i = 0
			sync_state.rpc(position, rotation, linear_velocity, angular_velocity)

var i = 0
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if !is_multiplayer_authority():
		if has_synced:
			print("sync")
			has_synced = false
			state.linear_velocity = synced_linear_velocity
			state.angular_velocity = synced_angular_velocity


@rpc("authority", "call_remote", "unreliable_ordered")
func sync_state(pos: Vector3, rot: Vector3, linear_vel: Vector3, angular_vel: Vector3):
	var position_delta = (position - pos).length()
	var rotation_delta = (rotation - rot).length()
	
	var linear_velocity_delta = (linear_velocity - linear_vel).length()
	var angular_velocity_delta = (angular_velocity - angular_vel).length()
	
	if position_delta >= 2.5:
		position = pos
		#synced_linear_velocity = linear_vel
		#has_synced = true
	
	if rotation_delta >= PI/4:
		rotation = rot
		#synced_angular_velocity = angular_vel
		#has_synced = true
	
	#if linear_velocity_delta >= 1.0:
		#synced_linear_velocity = linear_vel
		#has_synced = true
	#
	#if angular_velocity_delta >= PI/4:
		#synced_angular_velocity = angular_vel
		#has_synced = true
	
