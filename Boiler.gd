extends Node3D

var Energy=300.0;
@onready var interactor: InteractionBox3D = $Interactor
@export var EnergyLimit=300.0;
@export var CoalToEnergyMultiplier=10.0;
@export var roomManager:Node;
@export var submarine:RigidBody3D;

@rpc("any_peer","call_local","reliable")
func DepositCoal(coal:int):
	Energy+=coal*CoalToEnergyMultiplier

func _ready() -> void:
	interactor.interacted.connect(func():
		rpc("DepositCoal",roomManager.localplayer.coalHolding)
		roomManager.localplayer.coalHolding=0
		)

func _process(delta: float) -> void:
	submarine.hasPower=Energy > 1
	interactor.get_child(0).disabled=roomManager.localplayer.coalHolding==0
	Energy-=delta
	Energy =clamp(Energy,0.0,EnergyLimit)
	$Render.scale.y = (Energy/3.0)/100.0
	$Render.position.y=((Energy/3.0)/100.0)-1
