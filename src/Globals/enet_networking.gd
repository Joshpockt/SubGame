extends Node



func create_server() -> Error:
	var peer := ENetMultiplayerPeer.new()
	var error = peer.create_server(25565)
	if error == OK:
		multiplayer.multiplayer_peer = peer
		return OK
	else:
		return error


func join_server(address: String) -> Error:
	var peer := ENetMultiplayerPeer.new()
	var error = peer.create_client(address,25565)
	if error == OK:
		multiplayer.multiplayer_peer = peer
		return OK
	else:
		return error
