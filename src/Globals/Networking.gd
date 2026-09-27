extends Node


enum NetworkingType {
	NONE,
	ENET,
}

@warning_ignore_start("unused_signal")
signal start_game

var current_networking : NetworkingType = NetworkingType.NONE

## @deprecated: Use [Player].get_player
var players : Dictionary[int, Player] = {}
