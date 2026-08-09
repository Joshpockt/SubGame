extends RigidBody3D
class_name WormSegment

@onready var collider: CollisionShape3D = $Collider
@onready var mesh: MeshInstance3D = $Mesh
@onready var joint: Generic6DOFJoint3D = $Joint
@onready var blood: GPUParticles3D = $blood
@export var Segment=0

var gibbed=false
var seperated=false

@rpc("any_peer","call_local","reliable")
func Gib():
	get_parent().attachedSegments-=1
	gibbed=true
	seperated=true
	blood.emitting=true
	if joint:
		joint.queue_free()
	if collider:
		collider.queue_free()
	mass=.001
	mesh.hide()
	for i in get_parent().get_children():
		if i is WormSegment:
			if i.Segment > Segment && !i.seperated:
				get_parent().attachedSegments-=1
				seperated=true
