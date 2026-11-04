extends RigidBody3D

@onready var hitbox_3d: Hitbox3D = $Hitbox3D

@export var health := 10.0

func _ready() -> void:
	hitbox_3d.was_hit.connect(_on_hit)

func _on_hit(attack_data: AttackData):
	#print(attack_data.damage)
	health -= attack_data.damage
	if health <= 0.0:
		queue_free()
