@tool
extends Area3D
class_name InteractionBox3D

@export var interaction_time := 0.0

signal interacted
signal hover_entered
signal hover_exited
#var Progress = 1.0;

func _ready() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(4, true)

func interact():
	interacted.emit()

func hover():
	hover_entered.emit()
	
func hoverEND():
	hover_exited.emit()
