extends Node3D

const TORPEDO = preload("uid://bty4vx8metthl")


@onready var interaction_area: InteractionArea = $InteractionArea

func _ready() -> void:
	interaction_area.interacted.connect(_interacted)

func _process(delta: float) -> void:
	if Player.get_player(multiplayer.get_unique_id()).current_item != null:
		interaction_area.disable_interaction = true
	else:
		interaction_area.disable_interaction = false

func _interacted(peer_id: int) -> void:
	var player := Player.get_player(peer_id)
	if player.current_item == null:
		player.give_item(TORPEDO)
