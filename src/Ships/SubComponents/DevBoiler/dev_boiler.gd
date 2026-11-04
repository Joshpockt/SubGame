extends Node3D


@export var interior : SubInterior
#const COAL = preload("uid://bu8h31atua56k")
@onready var interaction_area: InteractionArea = $InteractionArea
@onready var gauge: Gauge = $Gauge


func _ready() -> void:
	interaction_area.interacted.connect(_interacted)

func _interacted(peer_id: int) -> void:
	var player := Player.get_player(peer_id)
	if player.current_item != null:
		var item := player.current_item
		if item.fuel_seconds > 0.0:
			interior.add_fuel(item.fuel_seconds)
			player.remove_item()

func _process(_delta: float) -> void:
	var player = Player.get_player(multiplayer.get_unique_id())
	if !player: return
	var current_player_item := Player.get_player(multiplayer.get_unique_id()).current_item
	if current_player_item != null:
		if current_player_item.fuel_seconds > 0.0:
			interaction_area.disable_interaction = false
		else:
			interaction_area.disable_interaction = true
	else:
		interaction_area.disable_interaction = true
	
	gauge.progress = interior.fuel_uniform
