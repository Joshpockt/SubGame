extends Control

# Ugh this script sucks...

const STEAM_LOBBY_LABEL = preload("uid://buku4xyly0j33")
const PLAYER_LABEL = preload("uid://bbkc5a3fb7cn7")

@onready var lobbies: VBoxContainer = %Lobbies
@onready var lobby_player_list: VBoxContainer = %LobbyPlayerList

@onready var starting_screen: Control = %StartingScreen
@onready var lobby_list: Control = %LobbyList
@onready var lobby: Control = %Lobby

@onready var host_button: Button = %HostButton
@onready var join_button: Button = %JoinButton

var current_lobby_id := 0

func _ready() -> void:
	hide_all()
	starting_screen.show()
	
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
	
	host_button.pressed.connect(_host_pressed)
	join_button.pressed.connect(_join_pressed)
	Steam.lobby_match_list.connect(_on_lobby_list_ready)
	Steam.lobby_joined.connect(_lobby_joined)
	_refresh_lobbies()
	
	var f = func(id:int):
		add_player_label(str(id))
	multiplayer.peer_connected.connect(f)


func _refresh_lobbies():
	Steam.requestLobbyList()


func create_server():
	print("Attempting to create server...")
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 8)
	Steam.lobby_created.connect(_server_created, CONNECT_ONE_SHOT)


func _server_created(connect_status: Steam.Result, lobby_id: int):
	if connect_status != Steam.Result.RESULT_OK: return
	
	print("Server successfully created with lobby id: ", str(lobby_id))
	current_lobby_id = lobby_id
	Steam.setLobbyJoinable(lobby_id, true)
	Steam.setLobbyType(lobby_id, Steam.LOBBY_TYPE_PUBLIC)
	Steam.setLobbyData(lobby_id, "roob", "true")
	Steam.setLobbyData(lobby_id, "name", Steam.getPersonaName())
	
	var peer : MultiplayerPeer = SteamMultiplayerPeer.new()
	peer.host_with_lobby(lobby_id)
	peer.server_relay = true
	multiplayer.multiplayer_peer = peer


func join_server(lobby_id: int) -> Error:
	Steam.joinLobby(lobby_id)
	var peer : MultiplayerPeer = SteamMultiplayerPeer.new()
	var error = peer.connect_to_lobby(lobby_id)
	if error == OK:
		multiplayer.multiplayer_peer = peer
		return OK
	else:
		return FAILED


func hide_all():
	starting_screen.hide()
	lobby_list.hide()
	lobby.hide()


func add_player_label(player_name: String):
	print("print")
	var label_instance : PlayerLobbyLabel = PLAYER_LABEL.instantiate()
	lobby_player_list.add_child(label_instance)
	label_instance.label.text = player_name


func remove_player_label(player_name: String):
	for child : PlayerLobbyLabel in lobby_player_list.get_children():
		if child.label.text == player_name:
			child.queue_free()
			return


func _join_lobby(lobby_id):
	Steam.joinLobby(lobby_id)


func _lobby_joined(lobby: int, permissions: int, locked: bool, response: int):
	if response == Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		current_lobby_id = lobby
		var peer : MultiplayerPeer = SteamMultiplayerPeer.new()
		peer.connect_to_lobby(lobby)
		multiplayer.multiplayer_peer = peer


func _host_pressed():
	create_server()
	add_player_label(str(multiplayer.get_unique_id()))
	hide_all()
	lobby.show()


func _join_pressed():
	hide_all()
	lobby_list.show()
	_refresh_lobbies()


func _on_lobby_list_ready(lobby_ids: Array):
	for child in lobbies.get_children():
		child.queue_free()
	
	for this_lobby_id in lobby_ids:
		var response = Steam.getLobbyData(this_lobby_id, "roob")
		if response != "true": continue
		
		var lobby_label : LobbyLabel = STEAM_LOBBY_LABEL.instantiate()
		lobbies.add_child(lobby_label)
		lobby_label.label.text = Steam.getLobbyData(this_lobby_id, "name")
		var f = _join_lobby.bind(this_lobby_id)
		lobby_label.button.pressed.connect(f)
