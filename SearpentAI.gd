extends Node3D

var EndPosition=Vector3.ZERO
var OldPos=Vector3.ZERO
@onready var head: RigidBody3D = $Head
@export var PathfindingNodes:Node3D
var speed=20.0;
var torque_strength = 20.0
var damping = 12.0
var MaxNodeDistance=80.0
var PathIndex=0
var CurrentPath=null
var Searching=false
var Max =0
var lockOnPos=Vector3.ZERO

@export var id=0

@onready var sync: MultiplayerSynchronizer = $Sync

var syncTime=10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !multiplayer.is_server(): return
	Searching=true
	await get_tree().create_timer(5).timeout
	print("starting")
	FindWanderSpot()
	
func FindWanderSpot():
	Searching=true
	print("finding wander path")
	var guestimate = head.global_position+Vector3(randi_range(-MaxNodeDistance,MaxNodeDistance),randi_range(-15,15),randi_range(-MaxNodeDistance,MaxNodeDistance))
	while Searching:
		for i in PathfindingNodes.get_children():
			if guestimate.distance_to(i.global_position) < 5:
				if i.global_position != EndPosition && i.global_position != OldPos && randi_range(1,10) == 1:
					OldPos=EndPosition
					EndPosition=i.global_position
					Searching=false
					break
		guestimate = head.global_position+Vector3(randi_range(-MaxNodeDistance,MaxNodeDistance),randi_range(-15,15),randi_range(-MaxNodeDistance,MaxNodeDistance))
	print(EndPosition)
	CurrentPath=PathfindingNodes.GeneratePathTo(round(head.global_position),round(EndPosition))
	if CurrentPath == null:
		Searching=true
		push_error("your fucked")
		return
	Max = CurrentPath.size()-1
	PathIndex=0


# Called every frame. 'delta' is the elapsed time since the previous frame.
var t = 0
func _physics_process(delta: float) -> void:
	if !multiplayer.is_server(): return
	t+=delta*3
	if Searching:return;
	if PathIndex==Max || CurrentPath.is_empty():
		FindWanderSpot()
		return
	var TargetPosition = CurrentPath[PathIndex]
	var dir = head.global_transform.basis.y
	head.apply_central_force(dir*speed)
	var desired = (TargetPosition - (head.global_position+(head.global_transform.basis.z*(sin(t)*4)))).normalized()
	var current = head.global_transform.basis.y

	var axis = current.cross(desired)
	var angle = acos(clamp(current.dot(desired), -1.0, 1.0))

	head.apply_torque(axis.normalized() * angle * torque_strength- head.angular_velocity * damping)
	if head.global_position.distance_to(TargetPosition) < 3:
		PathIndex+=1

@rpc("authority","call_local","reliable")
func SyncWurm(pos,rot):
	head.global_position=pos;
	head.global_rotation=rot


func _process(delta: float) -> void:
	lockOnPos=head.global_position
	#if multiplayer.is_server():
		#syncTime-=delta
		#if syncTime < 0:
			#syncTime=10
			#rpc("SyncWurm",head.global_position,head.global_rotation)
