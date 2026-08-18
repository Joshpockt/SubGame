extends Node

#ALERT, ATTENTION, CAUTION, CRITICAL, DANGER, SECURITY

#BUG, DEPRECATED, FIXME, HACK, TASK, TBD, TODO, WARNING

#INFO, NOTE, NOTICE, TEST, TESTING


func snap_to(from:Node3D,to:Node3D) -> void:
	from.global_position = to.global_position
	from.global_rotation = to.global_rotation
	
func lerp_to(from: Node3D, to: Node3D, weight: float) -> void:
	from.global_position = from.global_position.lerp(to.global_position, weight)
	from.global_rotation = from.global_rotation.slerp(to.global_rotation, weight)

const EXPLOSION = preload("res://explosion.tscn")

## @deprecated
func ExplodeAt(pos:Vector3, environment: Node, radius:float) -> void:
	var explosion : Node3D = EXPLOSION.instantiate()
	environment.add_child(explosion)
	explosion.global_position=pos
	explosion.ExplosionForce=radius
	explosion.get_child(0).emitting=true
## @deprecated
func is_host() -> bool:
	return multiplayer.get_unique_id() == 1

## @deprecated
func is_client() -> bool:
	return multiplayer.get_unique_id() != 1
