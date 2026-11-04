extends Area3D
class_name Hitbox3D

signal was_hit(attack_data: AttackData)

func _ready() -> void:
	collision_layer = 0b10000000
	collision_mask = 0b0

func hit(attack_data: AttackData):
	was_hit.emit(attack_data)
