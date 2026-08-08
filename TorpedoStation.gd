extends Node3D

var using=null
var beingUsed=false
@export var roomManager:Node
@onready var interactor: InteractionBox3D = $Interactor
@onready var player_seat: Node3D = $PlayerSeat
@onready var rotate: Node3D = $Rotate
@onready var view: TextureRect = $View
@onready var torpedo_view_anchor: Node3D = $"../../ExteriorViewport/ExteriorWorld/SubExterior/TorpedoViewAnchor"
var isClient=false
@export var LockOnSteps:int=100
@export var MaxLockOnDeviation=20
@onready var creatures: Node3D = $"../../ExteriorViewport/ExteriorWorld/Creatures"
var lockedOnto=null
var hookDelay=0
@export var submarine:RigidBody3D



@rpc("any_peer","call_remote","reliable")
func RequestUse(myId):
	if beingUsed&&roomManager.Players[myId] != using:return
	rpc("UseStation",myId)


func LockOn():
	var closest = LockOnSteps
	var closestDeviation=MaxLockOnDeviation
	var cl=null
	for step in LockOnSteps:
		for i in creatures.get_children():
			var lock = i.lockOnPos
			var toCam=torpedo_view_anchor.global_position.distance_to(lock)
			var toStep=(torpedo_view_anchor.global_position+(-torpedo_view_anchor.transform.basis.z*step)).distance_to(lock)
			if cl == null:
				cl=i
			if toCam < closest: closest=toCam
			if toStep < closestDeviation: 
				closestDeviation=toStep
				if toStep < closest:
					cl=i
	lockedOnto=cl
	

@rpc("authority","call_local","reliable")
func UseStation(id):
	hookDelay=1
	if beingUsed&&roomManager.Players[id] == using:
		beingUsed=false
		using=null
		isClient=false
		view.hide()
		return
	beingUsed=true
	using=roomManager.Players[id]
	isClient=false
	if Utils.isClient(id,multiplayer):
		view.show()
		isClient=true
	print("giving ownership")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactor.interacted.connect(func():
		if hookDelay > 0:
			return
		if multiplayer.is_server():
			RequestUse(1)
		else:
			rpc_id(1,"RequestUse",multiplayer.get_unique_id())
		)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire_torpedo") && roomManager.Players[multiplayer.get_unique_id()] == using:
		if multiplayer.is_server():
			submarine.RequestTorpedoFire(lockedOnto.id)
		else:
			submarine.rpc_id(1,"RequestTorpedoFire",lockedOnto.id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hookDelay > 0:
		hookDelay-=delta
	if beingUsed && using != null:
		using.mover.global_position=player_seat.global_position
		rotate.global_rotation=using.mover.global_rotation
		if isClient:
			if Input.is_action_just_pressed("interact"):
				isClient=false
				view.hide()
				if multiplayer.is_server():
					RequestUse(1)
				else:
					rpc_id(1,"RequestUse",multiplayer.get_unique_id())
				return
			LockOn()
			torpedo_view_anchor.global_rotation=using.mover.camera.global_rotation
		
