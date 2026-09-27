extends RigidBody3D
class_name SubExterior

static var throttle_input : float = 0.0
static var steering_input : float = 0.0

@export var max_linear_force := 10.0
@export var max_torque := 1.0

static var exterior_instance : SubExterior


func _ready() -> void:
	exterior_instance = self
	ScreenManager.register_screen($SubViewport, "FRONT")


func _physics_process(delta: float) -> void:
	#$GPUParticles3D.global_position = (linear_velocity * 2) + global_position
	#print(linear_velocity * 2)
	
	if SubInterior.interior_instance.fuel <= 0:
		return
	apply_central_force(
			Vector3.FORWARD.rotated(Vector3.UP,rotation.y) * throttle_input * max_linear_force)
	apply_torque(Vector3.DOWN * steering_input * max_torque)
	throttle_input = 0.0
	steering_input = 0.0
