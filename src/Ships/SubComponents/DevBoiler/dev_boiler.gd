extends Node3D

@onready var interaction_area: InteractionArea = $InteractionArea
#const COAL = preload("uid://bu8h31atua56k")

func _ready() -> void:
	interaction_area.interacted.connect(_interacted)

func _interacted(peer_id: int) -> void:
	var player := Player.get_player(peer_id)
	if player.current_item != null:
		var item := player.current_item
		if item.fuel_seconds > 0.0:
			SubInterior.interior_instance.add_fuel(item.fuel_seconds)
			player.remove_item()

func _process(_delta: float) -> void:
	var current_player_item := Player.get_player(multiplayer.get_unique_id()).current_item
	if current_player_item != null:
		if current_player_item.fuel_seconds > 0.0:
			interaction_area.disable_interaction = false
		else:
			interaction_area.disable_interaction = true
	else:
		interaction_area.disable_interaction = true
	
	$Node3D.rotation.z = - (SubInterior.interior_instance.fuel_uniform * 2 - 1) * PI * 0.8
