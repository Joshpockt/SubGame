extends Control

const STEAM_START = preload("uid://cn7pyubvhrcdq")
const ENET_START = preload("uid://b4vt0lg5kop5s")

@onready var enet_button: Button = %EnetButton
@onready var steam_button: Button = %SteamButton


func _ready() -> void:
	var one = func(): get_tree().change_scene_to_packed(ENET_START)
	var two = func(): get_tree().change_scene_to_packed(STEAM_START)
	
	enet_button.pressed.connect(one)
	steam_button.pressed.connect(two)
