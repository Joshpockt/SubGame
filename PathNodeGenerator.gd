extends Node3D

const NodeStepDistance=15
const PathStepDistance=5
const CastDistance=3
var nodePositions:Dictionary
@onready var startNode: Node3D = $Node

# Called when the node enters the scene tree for the first time.

	
const DIRECTIONS: Array[Vector3i] = [
	Vector3i(-1,-1,-1), Vector3i( 0,-1,-1), Vector3i( 1,-1,-1),
	Vector3i(-1,-1, 0), Vector3i( 0,-1, 0), Vector3i( 1,-1, 0),
	Vector3i(-1,-1, 1), Vector3i( 0,-1, 1), Vector3i( 1,-1, 1),

	Vector3i(-1, 0,-1), Vector3i( 0, 0,-1), Vector3i( 1, 0,-1),
	Vector3i(-1, 0, 0), Vector3i( 1, 0, 0),
	Vector3i(-1, 0, 1), Vector3i( 0, 0, 1), Vector3i( 1, 0, 1),

	Vector3i(-1, 1,-1), Vector3i( 0, 1,-1), Vector3i( 1, 1,-1),
	Vector3i(-1, 1, 0), Vector3i( 0, 1, 0), Vector3i( 1, 1, 0),
	Vector3i(-1, 1, 1), Vector3i( 0, 1, 1), Vector3i( 1, 1, 1),
]
	
func IterateNodePath(pos:Vector3i):
	await get_tree().process_frame
	for d in DIRECTIONS:
		var nodepos = pos+(d*NodeStepDistance)
		if nodePositions.has(nodepos):continue
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(pos,nodepos)
		var result = space_state.intersect_ray(query)
		if result:continue
		var nd = startNode.duplicate()
		add_child(nd)
		nd.global_position=nodepos
		nd.get_child(0).queue_free()
		nodePositions[nodepos]=true
		IterateNodePath(nodepos)

func GeneratePathTo(from:Vector3,target:Vector3):
	var at = from
	var max = 0
	var points:Dictionary
	var readablePoints:Array
	while true:
		var dir = round(at.direction_to(target))
		if at.distance_to(target) < 6:
			break
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(at,at+(dir*PathStepDistance*CastDistance))
		var result = space_state.intersect_ray(query)
		if !result:
			at+=(dir*PathStepDistance)
			readablePoints.append(at)
			var nd = startNode.duplicate()
			add_child(nd)
			nd.global_position=at
			points[at]=true
		else:
			var radius=PathStepDistance
			var noGo=false
			while !noGo:
				max+=1
				if max > 1000:
					print("target unlocatable")
					return
				var closest = 10000
				var cl=null;	
				for d in DIRECTIONS:
					var at2 = at+(Vector3(d)*radius)
					if points.has(at2):continue
					space_state = get_world_3d().direct_space_state
					query = PhysicsRayQueryParameters3D.create(at,at2)
					result = space_state.intersect_ray(query)
					if result:continue
					dir =round( at2.direction_to(target))
					space_state = get_world_3d().direct_space_state
					query = PhysicsRayQueryParameters3D.create(at,at2+((dir*PathStepDistance))*CastDistance)
					result = space_state.intersect_ray(query)
					if result:continue
					var dis = at2.distance_to(target)
					points[at2]=true
					if dis < closest:
						closest=dis
						cl=at2
				if cl != null:
					at=cl
					readablePoints.append(at)
					var nd = startNode.duplicate()
					add_child(nd)
					nd.global_position=at
					break 
				radius+=PathStepDistance
	return readablePoints
func _ready() -> void:
	await get_tree().create_timer(2).timeout
	#GeneratePathTo(Vector3(0,0,20),startNode.global_position)
	IterateNodePath(Vector3i(startNode.global_position))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
