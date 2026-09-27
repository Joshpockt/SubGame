extends Node3D

const COAL = preload("uid://bu8h31atua56k")

@onready var interaction_area: InteractionArea = $InteractionArea

func _ready() -> void:
	interaction_area.interacted.connect(_interacted)

func _interacted(peer_id: int) -> void:
	var player := Player.get_player(peer_id)
	if player.current_item == null:
		player.give_item(COAL)
