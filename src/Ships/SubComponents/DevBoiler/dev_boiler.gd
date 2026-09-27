extends Node3D

@onready var interaction_area: InteractionArea = $InteractionArea
#const COAL = preload("uid://bu8h31atua56k")

func _ready() -> void:
	interaction_area.interacted.connect(_interacted)

func _interacted(peer_id: int) -> void:
	var player := Networking.players[peer_id]
	if player.current_item != null:
		if player.current_item.fuel_seconds > 0.0:
			SubInterior.interior_instance.fuel += 30
			player.remove_item()

func _process(delta: float) -> void:
	$Node3D.rotation.z = - (SubInterior.interior_instance.fuel_uniform * 2 - 1) * PI * 0.8
