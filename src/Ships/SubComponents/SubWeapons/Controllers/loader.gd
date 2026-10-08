extends Node3D
class_name SubWeaponLoader

@export var required_ammo_type : AmmoItem.AmmunitionType

@export_group("Nodes")
@export var interaction_area : InteractionArea
@export var controller : SubWeaponController


func _ready() -> void:
	interaction_area.interacted.connect(_interacted)


func _interacted(peer_id: int) -> void:
	var player := Player.get_player(peer_id)
	if player.current_item != null:
		var item := player.current_item
		if item is AmmoItem:
			controller.add_ammo(item.ammo_count)
			player.remove_item()


func _process(_delta: float) -> void:
	var current_player_item := Player.get_player(multiplayer.get_unique_id()).current_item
	# I know this is kinda yucky but it works!
	if !controller.fully_loaded:
		if current_player_item != null:
			if current_player_item is AmmoItem:
				if current_player_item.ammunition_type == required_ammo_type:
					interaction_area.disable_interaction = false
					return
	
	interaction_area.disable_interaction = true
