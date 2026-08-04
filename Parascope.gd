extends Node3D

var inUse=false
var playerUsing=0
@export var roomManager:Node
@onready var camera_hook: Node3D = $CameraHook
@onready var player_seat: Node3D = $PlayerSeat
@onready var interactor: InteractionBox3D = $Interactor
@export var submarine:RigidBody3D


func RequestInteraction():
	if !Utils.isHost(multiplayer):
		rpc_id(1,"HandleInteraction",multiplayer.get_unique_id())
	else:
		HandleInteraction(1)

@rpc("authority","call_local","reliable")
func ChangeController(id:int):
	if id == 0&&inUse:
		submarine.set_multiplayer_authority(1)
		submarine.syncronizer.set_multiplayer_authority(1)
		submarine.inUse=false
		playerUsing=0
		await get_tree().create_timer(.1).timeout
		inUse=false
		return
	var mover = roomManager.Players[id].mover
	playerUsing=id
	inUse=true
	Utils.SnapTo(mover,player_seat)
	mover.posLerpTo=player_seat.global_position
	submarine.set_multiplayer_authority(id)
	submarine.syncronizer.set_multiplayer_authority(id)
	submarine.inUse=true
	if Utils.isClient(id,multiplayer):
		mover.ExternalCameraHook=camera_hook
		mover.tabout=true
		mover.updateTabout()
		
@rpc("any_peer","call_remote","reliable")
func HandleInteraction(id:int):
	if id == playerUsing:
		rpc("ChangeController",0)
		return
	if inUse:return
	rpc("ChangeController",id)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && Utils.isClient(playerUsing,multiplayer) && inUse:
		RequestInteraction()
		var mover = roomManager.Players[multiplayer.get_unique_id()].mover
		mover.ExternalCameraHook=null
		mover.tabout=false
		mover.updateTabout()


func _ready() -> void:
	interactor.interacted.connect(RequestInteraction)
