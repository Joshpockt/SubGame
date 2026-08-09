extends RigidBody3D
class_name SerpentSegment

@onready var joint_attachment: Node3D = $JointAttachment

var joint = Generic6DOFJoint3D.new()
var segments:Array
var segmentId=0

func InitializeJoint():
	joint.set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT,false)
	joint.set_flag_y(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT,false)
	joint.set_flag_z(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT,false)
	add_child(joint)
	joint.position=joint_attachment.position
	joint.node_a = NodePath("..")
	if segmentId == 1:
		joint.node_b=NodePath("../../Head")
	else:
		joint.node_b=NodePath("../../Body"+str(segmentId-1))
	
@rpc("any_peer","call_local","reliable")
func Gib():
	get_parent().isDead=true
	queue_free()

func _ready() -> void:
	for i in get_parent().get_children(): #Fill Segment Array
		if i is SerpentSegment:
			segments.append(i)
			if i == self:
				segmentId=segments.size()
	InitializeJoint()
	
