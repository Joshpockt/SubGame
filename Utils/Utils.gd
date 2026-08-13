class_name Utils

#ALERT, ATTENTION, CAUTION, CRITICAL, DANGER, SECURITY

#BUG, DEPRECATED, FIXME, HACK, TASK, TBD, TODO, WARNING

#INFO, NOTE, NOTICE, TEST, TESTING


static func SnapTo(from:Node3D,to:Node3D):
	from.global_position = to.global_position
	from.global_rotation = to.global_rotation
	
static func LerpTo(from: Node3D, to: Node3D, speed):
	from.global_position = from.global_position.lerp(to.global_position,speed)
	from.global_rotation = from.global_rotation.slerp(to.global_rotation,speed)

const EXPLOSION = preload("res://explosion.tscn")

static func ExplodeAt(pos:Vector3,environment,radius:float):
	var explosion = EXPLOSION.instantiate()
	environment.add_child(explosion)
	explosion.global_position=pos
	explosion.ExplosionForce=radius
	explosion.get_child(0).emitting=true


static func isHost(mult):
	return mult.get_unique_id() == 1

static func isClient(id:int,multiplayer):
	return multiplayer.get_unique_id() == id
