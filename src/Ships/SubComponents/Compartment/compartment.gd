@tool
extends Area3D
class_name Compartment

@export var compartment_shape: CollisionShape3D
@export var water_mesh: MeshInstance3D
@export var water_shape: CollisionShape3D
@export var bilge_speed := 0.0:
	set(value):
		bilge_speed = max(0.0, value)

var idk_change_this_name_lol := 0

@export_tool_button("Attempt to calculate volume") var volume_button = func():
	if not compartment_shape: return
	if compartment_shape.shape is BoxShape3D:
		var x = compartment_shape.shape.size.x
		var y = compartment_shape.shape.size.y
		var z = compartment_shape.shape.size.z
		compartment_volume = x * y * z

@export var size := Vector3.ONE:
	set(value):
		#if !Engine.is_editor_hint(): return
		size = value
		compartment_shape.shape.size = size
		water_mesh.mesh.size = size
		water_shape.shape.size = size

@export var compartment_volume : float

@export_range(0.0, 1.0) var fill_level := 0.0:
	set(value):
		fill_level = clamp(value, 0.0, 1.0)
		
		if !is_node_ready():
			await ready
		var s : float = compartment_shape.shape.size.y * fill_level
		var offset : float = (-(compartment_shape.shape.size.y - s) / 2) - 0.01
		water_mesh.mesh.size.y = s
		water_mesh.position.y = offset
		
		water_shape.shape.size.y = s
		water_shape.position.y = offset + 0.01
		
		if fill_level == 0.0:
			water_mesh.hide()
		else:
			water_mesh.show()

func _ready() -> void:
	fill_level = fill_level

func _physics_process(delta: float) -> void:
	#print("process")
	if idk_change_this_name_lol <= 0:
		remove_water(bilge_speed * delta)
	idk_change_this_name_lol -= 1

func add_water(cubic_meters: float):
	fill_level += cubic_meters / compartment_volume
	idk_change_this_name_lol = 2

func remove_water(cubic_meters: float):
	fill_level -= cubic_meters / compartment_volume
