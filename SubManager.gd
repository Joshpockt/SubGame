extends Node3D
@onready var hull_crack_spots: Node3D = $HullCrackSpots
@onready var sub_exterior: RigidBody3D = $"../ExteriorViewport/ExteriorWorld/SubExterior"

const HULLCRACK=preload("res://hull_crack.tscn")
@onready var hole_ref: MeshInstance3D = $HoleRef
var floodedAmount=0.0
@onready var water: Node3D = $Water
@onready var water_area: Area3D = $Water/WaterArea
var localplayer=null;
var hullcrackIds=0
@onready var boiler: Node3D = $Boiler

var syncCooldown=10

func HullCrack():
	var crackPos = hole_ref.to_global(sub_exterior.currentCollisionPoint)
	var crack = HULLCRACK.instantiate()
	hull_crack_spots.add_child(crack)
	crack.global_position=crackPos
	crack.look_at(global_position)
	crack.name=str(hullcrackIds)
	hullcrackIds+=1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sub_exterior.SubTookDamage.connect(HullCrack)

func syncData(floodedAmt,boileramt):
	floodedAmount=floodedAmt
	boiler.Energy=boileramt

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Water/InWater.visible=localplayer.mover.global_position.y < floodedAmount-1.6
	floodedAmount+=delta*hull_crack_spots.get_child_count()/40
	if hull_crack_spots.get_child_count() == 0 && floodedAmount > 0:
		floodedAmount-=delta/50
	if multiplayer.is_server():
		if syncCooldown > 0:
			syncCooldown-=delta
		else:
			syncCooldown=10
		rpc("syncData",floodedAmount,boiler.Energy)
	water.position.y=floodedAmount
