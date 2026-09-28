extends RigidBody3D
class_name SubExterior

signal sub_hit(collision_direction: Vector3, strength: float)

static var throttle_input : float = 0.0
static var steering_input : float = 0.0

@export var max_linear_force := 10.0
@export var max_torque := 1.0

static var exterior_instance : SubExterior


func _ready() -> void:
	exterior_instance = self
	ScreenManager.register_screen($SubViewport, "FRONT")
	var f = func(_collision_direction, _strength: float):
		print(multiplayer.get_unique_id(), ": ", "hit ", _collision_direction, ", ", _strength)
	sub_hit.connect(f)


func _physics_process(_delta: float) -> void:
	#print(get_multiplayer_authority())
	#$GPUParticles3D.global_position = (linear_velocity * 2) + global_position
	#print(linear_velocity * 2)
	
	if SubInterior.interior_instance.fuel <= 0:
		return
	apply_central_force(
			Vector3.FORWARD.rotated(Vector3.UP,rotation.y) * throttle_input * max_linear_force)
	apply_torque(Vector3.DOWN * steering_input * max_torque)
	throttle_input = 0.0
	steering_input = 0.0


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if !is_multiplayer_authority(): return
	
	for contact in get_contact_count():
		if state.get_contact_impulse(contact).length() >= 8:
			var collision_direction := to_local(state.get_contact_local_position(0)).normalized()
			var strength := state.get_contact_impulse(contact).length()
			sub_hit.emit(collision_direction, strength)
			sync_hit.rpc(collision_direction, strength)
		elif state.get_contact_local_velocity_at_position(0).length() >= 8:
			print("scrape: ", state.get_contact_local_velocity_at_position(0).length())

# could probably be authority but eh.
@rpc("any_peer", "call_remote", "reliable")
func sync_hit(collision_direction: Vector3, strength: float):
	sub_hit.emit(collision_direction)
