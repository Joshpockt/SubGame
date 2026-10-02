extends Node

enum {
	INTERIOR,
	EXTERIOR,
}

@onready var world: Node = $ExteriorWorld/World


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var interior_scene : PackedScene = load(SubmarineData.DEV[INTERIOR])
	var exterior_scene : PackedScene = load(SubmarineData.DEV[EXTERIOR])
	
	var exterior_instance : = exterior_scene.instantiate()
	world.add_child(exterior_instance)
	
	var interior_instance = interior_scene.instantiate()
	add_child(interior_instance)
