extends RigidBody3D

@export var target : Node3D

var t := 0.0

@onready var hitbox_3d: Hitbox3D = $Hitbox3D

#func _ready() -> void:
	#hitbox_3d.was_hit.connect(_on_hit)

func _physics_process(delta: float) -> void:
	if get_parent().get_child_count() < 7: return
	
	t += delta
	#print(cos(t * 0.1) * PI)
	var direction = global_position.direction_to(target.global_position).rotated(Vector3.UP, cos(t * 1.5) * PI * 0.05)# * PI)
	#print(direction)
	apply_central_force(direction * 5000)

#func _on_hit(_attack_data: AttackData):
	#print("hit")
