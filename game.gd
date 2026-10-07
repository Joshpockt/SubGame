extends Node

const DEV_INTERIOR = preload("uid://cuj2gpbf6tct6")

enum {
	INTERIOR,
	EXTERIOR,
}

@onready var world: Node = $ExteriorWorld/World


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var sub_scene : PackedScene = DEV_INTERIOR
	
	var sub_instance : SubInterior = sub_scene.instantiate()
	add_child(sub_instance)
	sub_instance.sub_exterior.reparent(world, false)
	sub_instance.sub_exterior.position = Vector3.ZERO
