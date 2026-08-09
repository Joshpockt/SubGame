class_name Utils

static func SnapTo(node:Node3D,node2:Node3D):
	node.global_position=node2.global_position
	node.global_rotation=node2.global_rotation
	
static func LerpTo(node:Node3D,node2:Node3D,speed):
	node.global_position=node.global_position.lerp(node2.global_position,speed)
	node.global_rotation=node.global_rotation.slerp(node2.global_rotation,speed)

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
