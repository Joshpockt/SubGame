extends Node

var players : Dictionary[int, Player] = {}

func is_host() -> bool:
	return multiplayer.get_unique_id() == 1

func is_client() -> bool:
	return multiplayer.get_unique_id() != 1

func is_id_mine(id) -> bool:
	return multiplayer.get_unique_id() == id
