@tool
extends Area3D
class_name Compartment

const GHOST_SPEED := 10.0

signal water_added(ammount: float)

@export var gaps : Array[CompartmentGap]

@export var compartment_shape: CollisionShape3D
@export var water_mesh: MeshInstance3D
@export var water_shape: CollisionShape3D

var global_water_level : float:
	get():
		return global_position.y + (fill_level * compartment_shape.shape.size.y)
var accumulated_water := 0.0

@export_tool_button("Attempt to calculate volume") var volume_button = func():
	if not compartment_shape: return
	if compartment_shape.shape is BoxShape3D:
		var x = compartment_shape.shape.size.x
		var y = compartment_shape.shape.size.y
		var z = compartment_shape.shape.size.z
		compartment_volume = x * y * z

@export var size := Vector3.ONE:
	set(value):
		if !is_node_ready():
			await ready
		
		size = value
		_update_size()
		_update_fill_level()

@export var compartment_volume : float

@export_range(0.0, 1.0) var fill_level := 0.0:
	set(value):
		fill_level = clamp(value, 0.0, 1.0)
		
		if !is_node_ready():
			await ready
		#_update_fill_level()

@export var fill_volume : float:
	set(value):
		fill_level = value / compartment_volume
	get():
		return fill_level * compartment_volume


func _update_size():
	compartment_shape.shape.size = size
	compartment_shape.position.y = compartment_shape.shape.size.y / 2
	water_mesh.mesh.size = size
	water_shape.shape.size = size


func _update_fill_level():
	var s : float = compartment_shape.shape.size.y * fill_level
	var offset : float = (s/2) - 0.01
	water_mesh.mesh.size.y = s
	#water_mesh.position.y = s
	water_mesh.position.y = offset
	
	water_shape.shape.size.y = s
	water_shape.position.y = offset + 0.01


func _ready() -> void:
	_update_size()
	_update_fill_level()
	fill_level_ghost = fill_level


var fill_level_ghost : float = 0.0
func _process(delta: float) -> void:
	var compartments : Array[Compartment]
	
	
	$Label3D.text = str(snapped(fill_volume, 0.001))
	
	fill_level_ghost = lerp(fill_level_ghost, fill_level, GHOST_SPEED * delta)
	
	if fill_level_ghost <= 0.01:
		water_mesh.hide()
		return
	else:
		water_mesh.show()
	
	var s : float = compartment_shape.shape.size.y * fill_level_ghost
	#var s : float = compartment_shape.shape.size.y * fill_level
	var offset : float = (s/2) - 0.01
	water_mesh.mesh.size.y = s
	#water_mesh.position.y = s
	water_mesh.position.y = offset
	
	water_shape.shape.size.y = s
	water_shape.position.y = offset + 0.01

#var last_level := 0.0
func _update(_delta: float):
	#print(fill_level - last_level)
	#last_level = fill_level
	fill_volume += accumulated_water
	accumulated_water = 0.0

#func _physics_process(delta: float) -> void:
	#if Engine.is_editor_hint(): return
	
	#if idk_change_this_name_lol <= 0:
		#remove_water(bilge_speed * delta)
	#idk_change_this_name_lol -= 1


func add_water(cubic_meters: float):
	accumulated_water += cubic_meters
	#idk_change_this_name_lol = 2
	water_added.emit(cubic_meters)


func remove_water(cubic_meters: float):
	accumulated_water -= cubic_meters


func get_section_volume(size_y: float) -> float:
	return compartment_shape.size.x * compartment_shape.size.y * size_y
