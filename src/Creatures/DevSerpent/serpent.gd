extends RigidBody3D

@export var target : Node3D

var t := 0.0
func _physics_process(delta: float) -> void:
	t += delta
	#print(cos(t * 0.1) * PI)
	var direction = global_position.direction_to(target.global_position).rotated(Vector3.UP, cos(t * 1.5) * PI * 0.05)# * PI)
	#print(direction)
	apply_central_force(direction * 5000)
