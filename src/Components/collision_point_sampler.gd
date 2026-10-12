extends Node3D
class_name CollisionPointSampler

@export_group("Collision")
@export_flags_3d_physics var layer : int = 1

func get_overlapping_areas() -> Array[Area3D]:
	var server = PhysicsServer3D
	var space : PhysicsDirectSpaceState3D = server.space_get_direct_state(get_viewport().find_world_3d().space)
	
	var point_query := PhysicsPointQueryParameters3D.new()
	point_query.collide_with_areas = true
	point_query.collide_with_bodies = false
	point_query.collision_mask = layer
	point_query.position = global_position
	
	var result : Array[Area3D]= []
	
	for thing in space.intersect_point(point_query):
		result.append(thing["collider"])
	
	return result

func get_overlapping_bodys() -> Array[Node3D]:
	var server = PhysicsServer3D
	var space : PhysicsDirectSpaceState3D = server.space_get_direct_state(get_viewport().find_world_3d().space)
	
	var point_query := PhysicsPointQueryParameters3D.new()
	point_query.collide_with_areas = false
	point_query.collide_with_bodies = true
	point_query.collision_mask = layer
	point_query.position = global_position
	
	var result : Array[Node3D]= []
	
	for thing in space.intersect_point(point_query):
		result.append(thing["collider"])
	
	return result
