extends Node


enum NetworkingType {
	NONE,
	ENET,
	STEAM,
}

@warning_ignore_start("unused_signal")
signal start_game

## @deprecated
var current_networking : NetworkingType = NetworkingType.NONE

## @deprecated: Use [Player].get_player
var players : Dictionary[int, Player] = {}

func _ready() -> void:
	multiplayer.peer_connected.connect(_peer_joined)

func _peer_joined(id):
	print(multiplayer.get_unique_id(),": Peer joined, ", id)
