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

@onready var chomper: RayCast3D = $Head/chomper


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

var isRetreating=false

#Segment Stuff
var Segments:Array;
var attachedSegments=0;

var id = 0
var isDead=false

@onready var left_beak: MeshInstance3D = $Head/left_beak/beak
@onready var right_beak: MeshInstance3D = $Head/right_beak/beak
@onready var top_beak: MeshInstance3D = $Head/top_beak


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
	if !head: return
	if CurrentPathIndex>=CurrentPathSize || CurrentPath.is_empty():
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
		
func Attack():
	if chomper.is_colliding() && !isRetreating:
		print("Chomp!")
		isRetreating=true
		chomp=27

func Retreating(delta):
	if !head: return
	t+=delta*3 #for sin
	
	if global_position.distance_to(SoundAreaFollowing.global_position) > 60 && isRetreating:
		isRetreating=false
		return
	
	if GettingPath:return;
	if CurrentPathIndex>=CurrentPathSize || CurrentPath.is_empty():
		FindWanderSpot()
		return
		
	var TargetPosition = CurrentPath[CurrentPathIndex]
	var dir = -head.global_transform.basis.z
	head.apply_central_force(dir*chase_speed)
	var desired = (TargetPosition - (head.global_position+(head.global_transform.basis.x*(sin(t)*8)))).normalized()
	var current = -head.global_transform.basis.z

	var axis = current.cross(desired)
	var angle = acos(clamp(current.dot(desired), -1.0, 1.0))

	head.apply_torque(axis.normalized() * angle * (torque_strength+40)- head.angular_velocity * torque_damping)
	if head.global_position.distance_to(TargetPosition) < 3:
		CurrentPathIndex+=1


func Follow(delta):
	t+=delta*3 #for sin
	if isRetreating:
		Retreating(delta)
		return
	Attack()
	#Need to allow pathfinding if sound not in view!
	
	#if GettingPath:return;
	#if CurrentPathIndex==CurrentPathSize || CurrentPath.is_empty():
		#FindWanderSpot()
		#return
		#
	#var TargetPosition = CurrentPath[CurrentPathIndex]
	
	var TargetPosition = SoundAreaFollowing.global_position
	var dir = -head.global_transform.basis.z
	head.apply_central_force(dir*chase_speed)
	var desired = (TargetPosition - (head.global_position+(head.global_transform.basis.x*(sin(t)*8)))).normalized()
	var current = -head.global_transform.basis.z

	var axis = current.cross(desired)
	var angle = acos(clamp(current.dot(desired), -1.0, 1.0))

	head.apply_torque(axis.normalized() * angle * (torque_strength+20)- head.angular_velocity * torque_damping)
	if head.global_position.distance_to(TargetPosition) < 3:
		CurrentPathIndex+=1


func _physics_process(delta: float) -> void:
	if isDead:set_physics_process(false);
	if isDead:return;
	if SoundAreaFollowing != null: #Wander unless a sound area is detected
		Follow(delta); return
	Wander(delta)


func SetLockOnOffset(): #the position where a locked on torpedo will goto
	for i in Segments:
		if i == null: continue
		LockOntoOffset=i.global_position
		return
	LockOntoOffset=head.global_position
	
func DetectSound(): #Searches for sound areas intersecting SoundArea
	var closest=999
	for i in SoundArea.get_overlapping_areas():
		var dis = head.global_position.distance_to(i.global_position)
		if dis < closest:
			SoundAreaFollowing=i
			closest=dis
			
var jaw_t=0
var jaw_m=0.0
var chomp=0.0
func animateJaw(delta):

	if SoundAreaFollowing != null:
		if global_position.distance_to(SoundAreaFollowing.global_position) < 45 && !isRetreating:
			jaw_m=lerp(jaw_m,27.0,5*delta)
		else:
			jaw_m=lerp(jaw_m,0.0,5.0*delta)
	jaw_t+=delta*2
	var sinuh=(sin(jaw_t)-1)
	sinuh-=jaw_m
	if chomp > 0:
		sinuh=-chomp
		chomp-=delta*(chomp*20)
	left_beak.rotation_degrees.y=-sinuh
	right_beak.rotation_degrees.y=sinuh
	top_beak.rotation_degrees.x=-sinuh

func _process(_delta: float) -> void:
	if head != null:
		global_position=head.global_position
		SetLockOnOffset()
	else:
		LockOntoOffset=Vector3.ZERO
	if isDead:return;
	animateJaw(_delta)
	if !isServer:return
	_detect_interval-=_delta
	if _detect_interval <= 0:
		_detect_interval=DetectInterval
		DetectSound()
