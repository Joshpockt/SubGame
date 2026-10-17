extends Node

var current_lobby_id : int

func init_steam():
	print("Attempting to initalize steam...")
	var initialize_response: Dictionary = Steam.steamInitEx(480, true)
	match initialize_response["status"]:
		0:
			print("Steam successfully initalized.")
		1:
			print("Steam failed to initalize, with a generic error")
		2:
			print("Could not initalize Steam. Steam client is not running.")
		4:
			print("Could not initalize Steam. Steam client is out of date")
		_:
			pass


func create_server():
	print("Attempting to create server...")
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 8)
	Steam.lobby_created.connect(_server_created, CONNECT_ONE_SHOT)


func _server_created(connect_status: Steam.Result, lobby_id: int):
	if connect_status != Steam.Result.RESULT_OK: return
	
	print("Server successfully created with lobby id: ", str(lobby_id))
	current_lobby_id = lobby_id
	Steam.setLobbyJoinable(lobby_id, true)
	Steam.setLobbyType(lobby_id, Steam.LOBBY_TYPE_FRIENDS_ONLY)
	Steam.setLobbyData(lobby_id, "roob", "true")
	Steam.setLobbyData(lobby_id, "name", Steam.getPersonaName())
	
	var peer : MultiplayerPeer = SteamMultiplayerPeer.new()
	peer.host_with_lobby(lobby_id)
	peer.server_relay = true
	multiplayer.multiplayer_peer = peer


func join_server(lobby_id: int) -> Error:
	var peer : MultiplayerPeer = SteamMultiplayerPeer.new()
	var error = peer.connect_to_lobby(lobby_id)
	if error == OK:
		multiplayer.multiplayer_peer = peer
		return OK
	else:
		return FAILED
