extends Node


func _ready() -> void:
	multiplayer.peer_connected.connect(_peer_joined)


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


func _peer_joined(id):
	print(multiplayer.get_unique_id(),": Peer joined, ", id)
