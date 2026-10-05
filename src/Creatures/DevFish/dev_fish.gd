extends RigidBody3D

var target : Node3D

@onready var ray_cast_3d: RayCast3D = $RayCast3D

func _ready() -> void:
	$SonarEmitter.volume = 10

var i = 0
func _physics_process(delta: float) -> void:
	#target = SubExterior.exterior_instance
	if target:
		var dir = target.global_position - global_position
		apply_central_force(dir * 2.5)
	
	if is_multiplayer_authority():
		i += 1
		if i >= 5:
			i = 0
			sync_position.rpc(position, rotation)


@rpc("authority", "call_remote", "unreliable_ordered")
func sync_position(pos: Vector3, rot: Vector3):
	position = pos
	rotation = rot
