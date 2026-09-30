extends Node3D

@onready var interaction_area: InteractionArea = $InteractionArea

func _ready() -> void:
	var f = func(_id): remove.rpc()
	interaction_area.interacted.connect(f)
	pass

@rpc("any_peer", "call_local", "reliable")
func remove():
	queue_free()
