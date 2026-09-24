extends Node


enum NetworkingType {
	NONE,
	ENET,
}

@warning_ignore_start("unused_signal")
signal start_game

var current_networking : NetworkingType = NetworkingType.NONE

var players : Dictionary[int, Player] = {}
