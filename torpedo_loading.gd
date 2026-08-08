extends Node3D

@onready var interactor: InteractionBox3D = $Interactor
@export var roomManager:Node;
@export var submarine:RigidBody3D;

@rpc("any_peer","call_local","reliable")
func DepositTorpedo():
	submarine.torpedoLoaded=true

func _ready() -> void:
	interactor.interacted.connect(func():
		if !roomManager.localplayer.hasTorpedo: return
		rpc("DepositTorpedo")
		roomManager.localplayer.hasTorpedo=false
		)
