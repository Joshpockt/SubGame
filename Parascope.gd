extends Node3D

var in_use = false
var playerUsing = 0
@export var room_manager: Node
@onready var camera_hook: Node3D = $CameraHook
@onready var player_seat: Node3D = $PlayerSeat
@onready var interactor: InteractionBox3D = $Interactor
@export var submarine:RigidBody3D


func RequestInteraction() -> void:
	if !Utils.isHost():
		rpc_id(1,"HandleInteraction",multiplayer.get_unique_id())
	else:
		HandleInteraction(1)


@rpc("authority","call_local","reliable")
func ChangeController(id:int) -> void:
	if id == 0 && in_use:
		submarine.set_multiplayer_authority(1)
		submarine.syncronizer.set_multiplayer_authority(1)
		submarine.in_use = false
		playerUsing = 0
		await get_tree().create_timer(0.1).timeout
		in_use = false
		return
	var mover = room_manager.Players[id].mover
	playerUsing = id
	in_use = true
	Utils.snap_to(mover, player_seat)
	mover.posLerpTo = player_seat.global_position
	submarine.set_multiplayer_authority(id)
	submarine.syncronizer.set_multiplayer_authority(id)
	submarine.in_use = true
	if NetworkUtilitys.is_client():
		mover.ExternalCameraHook = camera_hook
		mover.tabout = true
		mover.updateTabout()


@rpc("any_peer","call_remote","reliable")
func HandleInteraction(id:int) -> void:
	if id == playerUsing:
		rpc("ChangeController",0)
		return
	if in_use:return
	rpc("ChangeController",id)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && NetworkUtilitys.is_id_mine(playerUsing) && in_use:
		RequestInteraction()
		var mover = room_manager.Players[multiplayer.get_unique_id()].mover
		mover.ExternalCameraHook = null
		mover.tabout = false
		mover.updateTabout()


func _ready() -> void:
	interactor.interacted.connect(RequestInteraction)
