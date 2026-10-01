@tool
extends Node

const DIRECTIONS = [
	Vector3i.FORWARD,
	Vector3i.BACK,
	Vector3i.LEFT,
	Vector3i.RIGHT,
	Vector3i.UP,
	Vector3i.DOWN,
]

@export_tool_button("start!") var f = func(): start()
@export var size := 5.0
@export var max_i := 100




@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var multi_mesh_instance_3d: MultiMeshInstance3D = $MultiMeshInstance3D


var i = 0
func start():
	var start_time = Time.get_ticks_msec()
	var list : Array[Vector3i] = []
	var queue : Array[Vector3i] = [Vector3i.ZERO]
	
	list = []
	i = 0
	
	while !queue.is_empty() and i < max_i:
		var vec : Vector3i = queue.pop_front()
		var hit := false
		#i += 1
		
		#var cont := false
		if list.has(vec):
			continue
		
		for dir in DIRECTIONS:
			if list.has(vec + dir):
				ray_cast_3d.position = (vec + dir) * size
				ray_cast_3d.target_position = -dir * size
				ray_cast_3d.force_raycast_update()
				if ray_cast_3d.is_colliding():
					hit = true
					break
		
		if hit:
			continue
		else:
			list.append(vec)
			i += 1
			for dir in DIRECTIONS:
				queue.append(vec + dir)
	var end_time := Time.get_ticks_msec()
	print("done!")
	print("time: ", end_time - start_time, "ms")
	multi_mesh_instance_3d.multimesh.instance_count = 0
	multi_mesh_instance_3d.multimesh.instance_count = list.size()
	for point in list.size():
		var transform = Transform3D(Basis.IDENTITY, list[point] * size)
		multi_mesh_instance_3d.multimesh.set_instance_transform(point, transform)
		#var node : Node3D = PATH_FINDER_NODE.instantiate()
		##print(node)
		#nodes.add_child(node)
		#node.name = str(0)
		#node.owner = EditorInterface.get_edited_scene_root()
		#node.position = point * size
