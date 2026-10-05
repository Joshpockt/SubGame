extends Node3D
class_name SonarListener



enum SonarType {
	GENERIC,
	SUB,
	CREATURE,
	GEOLOGIC,
	SONAR,
}

func get_tracks() -> Array[SonarTrack]:
	var server = PhysicsServer3D
	var space : PhysicsDirectSpaceState3D = server.space_get_direct_state(get_viewport().find_world_3d().space)
	
	var point_query := PhysicsPointQueryParameters3D.new()
	point_query.collide_with_areas = true
	point_query.collide_with_bodies = false
	point_query.collision_mask = 0b10000
	point_query.position = global_position
	
	var sonar_emitters := space.intersect_point(point_query)
	
	if sonar_emitters.is_empty():
		return []
	#print(sonar_emitters)
	
	var ray_query := PhysicsRayQueryParameters3D.new()
	ray_query.collision_mask = 0b1
	ray_query.from = global_position
	
	var result : Array[SonarTrack] = []
	
	for emitter in sonar_emitters:
		var emitter_object = emitter["collider"]
		if emitter_object is SonarEmitter:
			ray_query.to = emitter_object.global_position
			var ray_result := space.intersect_ray(ray_query)
			if ray_result.has("rid"):
				continue
			else:
				var track = SonarTrack.new()
				var distance = global_position.distance_to(emitter_object.global_position)
				track.position = emitter_object.global_position
				track.type = emitter_object.type
				track.strength = (emitter_object.volume_exp - distance)
				result.append(track)
	
	#print(result)
	return result
