extends Node
class_name CameraShakeNodeExample

@export var shake_node : CameraShake3DNode

func _process(delta: float) -> void:
	# test input
	if Input.is_key_pressed(KEY_1):
		shake_node._custom_shake(1, 0.05)

	elif Input.is_key_pressed(KEY_2):
		shake_node._custom_shake(0.9, 0.1)

	elif Input.is_key_pressed(KEY_3):
		shake_node._custom_shake(0.8, 0.25)
		
	elif Input.is_key_pressed(KEY_4):
		shake_node._custom_shake(0.7, 0.5)
