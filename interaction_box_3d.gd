@tool
extends Area3D
class_name InteractionBox3D

signal interacted
signal hovered
signal hoveredEND

func _ready() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(4, true)

func interact():
	interacted.emit()

func hover():
	hovered.emit()
	
func hoverEND():
	hoveredEND.emit()
