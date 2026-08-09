extends Enemy
class_name Serpent

var isServer=true

@onready var head: RigidBody3D = $Head

@export var PathfindingNodes:Node3D

@export_category("Serpent Config")
@export var wander_speed=20.0
@export var chase_speed=50.0
@export var DetectInterval=1.0
@export var torque_strength = 20.0
@export var torque_damping = 12.0
@export var MaxSearchDistance=80.0
@export var MinSearchDistance=80.0
@export var SegmentResyncIntervals=10.0

@onready var SoundArea: Area3D = $SoundDetector

#Sound Detection Stuff
var _detect_interval=0.0
var SoundAreaFollowing=null

#Pathfinding Stuff
var GoalPosition=Vector3.ZERO
var CurrentPathIndex=0
var CurrentPath=null
var GettingPath=true
var CurrentPathSize =0

#Segment Stuff
var Segments:Array;
var attachedSegments=0;

var id = 0
var isDead=false


func fillSegmentArray():
	for i in get_children():
		if i is SerpentSegment:
			Segments.append(i)
	attachedSegments=Segments.size()
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	isServer=multiplayer.is_server()
	fillSegmentArray()
	
	if !isServer:  #Disables for clients, all enemys are handled by server and replicated, excluding LockOnOffset
		set_physics_process(false)
		return

	await get_tree().create_timer(5).timeout #Temporary Start Delay
	print("starting")
	FindWanderSpot()
	
func FindWanderSpot(): #SUBJECT TO CHANGE
	GettingPath=true
	print("Finding wander path")
	var PotentialGoal = head.global_position+Vector3(randi_range(-MaxSearchDistance,MaxSearchDistance),randi_range(-15,15),randi_range(-MaxSearchDistance,MaxSearchDistance))
	while GettingPath:
		if PotentialGoal.distance_to(global_position) < MinSearchDistance:
			PotentialGoal = head.global_position+Vector3(randi_range(-MaxSearchDistance,MaxSearchDistance),randi_range(-15,15),randi_range(-MaxSearchDistance,MaxSearchDistance))
			continue
		for i in PathfindingNodes.get_children():
			if PotentialGoal.distance_to(i.global_position) < 5:
				if i.global_position != GoalPosition:
					GoalPosition=i.global_position
					GettingPath=false
					break
		PotentialGoal = head.global_position+Vector3(randi_range(-MaxSearchDistance,MaxSearchDistance),randi_range(-15,15),randi_range(-MaxSearchDistance,MaxSearchDistance))
	print(GoalPosition)
	CurrentPath=PathfindingNodes.GeneratePathTo(round(head.global_position),round(GoalPosition))
	if CurrentPath == null:
		GettingPath=true
		push_error("Pathfinding to goal failed! FUCK")
		return
	CurrentPathSize = CurrentPath.size()-1
	CurrentPathIndex=0


var t = 0
func Wander(delta):
	t+=delta*3 #for sin
	
	if GettingPath:return;
	if CurrentPathIndex==CurrentPathSize || CurrentPath.is_empty():
		FindWanderSpot()
		return
		
	var TargetPosition = CurrentPath[CurrentPathIndex]
	var dir = -head.global_transform.basis.z
	head.apply_central_force(dir*wander_speed)
	var desired = (TargetPosition - (head.global_position+(head.global_transform.basis.x*(sin(t)*3)))).normalized()
	var current = -head.global_transform.basis.z

	var axis = current.cross(desired)
	var angle = acos(clamp(current.dot(desired), -1.0, 1.0))

	head.apply_torque(axis.normalized() * angle * torque_strength- head.angular_velocity * torque_damping)
	if head.global_position.distance_to(TargetPosition) < 3:
		CurrentPathIndex+=1
		

func Follow(delta):
	t+=delta*3 #for sin
	
	#if GettingPath:return;
	#if CurrentPathIndex==CurrentPathSize || CurrentPath.is_empty():
		#FindWanderSpot()
		#return
		#
	#var TargetPosition = CurrentPath[CurrentPathIndex]
	var TargetPosition = SoundAreaFollowing.global_position
	var dir = head.global_transform.basis.y
	head.apply_central_force(dir*wander_speed)
	var desired = (TargetPosition - (head.global_position+(head.global_transform.basis.z*(sin(t)*4)))).normalized()
	var current = head.global_transform.basis.y

	var axis = current.cross(desired)
	var angle = acos(clamp(current.dot(desired), -1.0, 1.0))

	head.apply_torque(axis.normalized() * angle * torque_strength- head.angular_velocity * torque_damping)
	if head.global_position.distance_to(TargetPosition) < 3:
		CurrentPathIndex+=1


func _physics_process(delta: float) -> void:
	if isDead:set_physics_process(false);
	if SoundAreaFollowing != null: #Wander unless a sound area is detected
		Follow(delta); return
	Wander(delta)


func SetLockOnOffset(): #the position where a locked on torpedo will goto
	for i in Segments:
		if i == null: continue
		LockOntoOffset=i.global_position
		return
	LockOntoOffset=head.global_position
	


func _process(_delta: float) -> void:
	SetLockOnOffset()
	global_position=head.global_position
	if !isServer:return
	_detect_interval-=_delta
	if _detect_interval <= 0:
		_detect_interval=DetectInterval
		var closest=999
		for i in SoundArea.get_overlapping_areas():
			var dis = head.global_position.distance_to(i.global_position)
			if dis < closest:
				SoundAreaFollowing=i
				closest=dis
