extends Node3D
@onready var pathfinding_nodes: Node3D = $"../PathfindingNodes"

var creatureIds=1
var creatures:Dictionary
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in get_children():
		i.PathfindingNodes=pathfinding_nodes
		i.id=creatureIds
		creatures[creatureIds]=i
		creatureIds+=1
