extends RigidBody3D
class_name SubExterior

signal sub_hit(collision_direction: Vector3, strength: float)

static var throttle_input : float = 0.0
static var vertical_input : float = 0.0
static var steering_input : float = 0.0

var damage_on_cooldown := false

@export var max_linear_force := 10.0
@export var max_vertical_force := 5.0
@export var max_torque := 1.0


static var exterior_instance : SubExterior


func _ready() -> void:
	exterior_instance = self
	ScreenManager.register_screen($SubViewport, "FRONT")


func _physics_process(_delta: float) -> void:
	#print(get_multiplayer_authority())
	#$GPUParticles3D.global_position = (linear_velocity * 2) + global_position
	#print(linear_velocity * 2)
	
	if SubInterior.interior_instance.fuel <= 0:
		return
	apply_central_force(
			Vector3.FORWARD.rotated(Vector3.UP,rotation.y) * throttle_input * max_linear_force)
	apply_central_force(Vector3.UP * vertical_input * max_vertical_force)
	apply_torque(Vector3.DOWN * steering_input * max_torque)
	throttle_input = 0.0
	steering_input = 0.0


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if !is_multiplayer_authority(): return
	if damage_on_cooldown: return
	
	for contact in get_contact_count():
		if state.get_contact_impulse(contact).length() >= 5:
			var collision_direction := to_local(state.get_contact_local_position(0)).normalized()
			var strength := state.get_contact_impulse(contact).length()
			sub_hit.emit(collision_direction, strength)
			sync_hit.rpc(collision_direction, strength)
			
			damage_on_cooldown = true
			var f = func(): damage_on_cooldown = false
			get_tree().create_timer(0.35).timeout.connect(f)
			
		elif state.get_contact_local_velocity_at_position(contact).length() >= 2:
			var collision_direction := to_local(state.get_contact_local_position(contact)).normalized()
			var strength := state.get_contact_local_velocity_at_position(contact).length()
			sub_hit.emit(collision_direction, strength)
			sync_hit.rpc(collision_direction, strength)
			
			damage_on_cooldown = true
			var f = func(): damage_on_cooldown = false
			get_tree().create_timer(0.25).timeout.connect(f)
			
			#print("scrape: ", state.get_contact_local_velocity_at_position(0).length())

# could probably be authority but eh.
@rpc("any_peer", "call_remote", "reliable")
func sync_hit(collision_direction: Vector3, strength: float):
	sub_hit.emit(collision_direction, strength)
