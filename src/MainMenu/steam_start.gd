extends Control

# Ugh this script sucks...

const STEAM_LOBBY_LABEL = preload("uid://buku4xyly0j33")
const PLAYER_LABEL = preload("uid://bbkc5a3fb7cn7")
const GAME = preload("uid://dgvqg2yagkuep")

@onready var lobbies: VBoxContainer = %Lobbies
@onready var lobby_player_list: VBoxContainer = %LobbyPlayerList

@onready var starting_screen: Control = %StartingScreen
@onready var lobby_list: Control = %LobbyList
@onready var lobby: Control = %Lobby

@onready var host_button: Button = %HostButton
@onready var join_button: Button = %JoinButton

@onready var start_game_button: Button = %StartGame

var current_lobby_id := 0

func _ready() -> void:
	print(multiplayer.multiplayer_peer)
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
	var f2 = func(id:int):
		remove_player_label(str(id))
	multiplayer.peer_disconnected.connect(f2)
	var f3 = func():
		rpc("start_game")
	start_game_button.pressed.connect(f3)


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
	peer.create_host(0)
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
	#print("print")
	var label_instance : PlayerLobbyLabel = PLAYER_LABEL.instantiate()
	lobby_player_list.add_child(label_instance)
	label_instance.label.text = player_name


func remove_player_label(player_name: String):
	for child : PlayerLobbyLabel in lobby_player_list.get_children():
		if child.label.text == player_name:
			child.queue_free()
			return


func _join_lobby(lobby_id):
	print("attempting to join lobby: ", lobby_id)
	Steam.joinLobby(lobby_id)


func _lobby_joined(lobby_id: int, _permissions: int, _locked: bool, response: int):
	
	if response == Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		var server_steam_id = Steam.getLobbyOwner(lobby_id)
		
		if server_steam_id != Steam.getSteamID():
			
			var peer : MultiplayerPeer = SteamMultiplayerPeer.new()
			peer.create_client(server_steam_id, 0)
			peer.server_relay = true
			multiplayer.multiplayer_peer = peer
			
			add_player_label(str(multiplayer.get_unique_id()))
			hide_all()
			lobby.show()
		else:
			match response:
				Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST:
					printerr("Failed joining lobby %s, this lobby no longer exists.")
				Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED:
					printerr("Failed joining lobby %s, you don't have permission to join this Lobbies.")
				Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_FULL:
					printerr("Failed joining lobby %s, the lobby is now full.")
				Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_ERROR:
					printerr("Failed joining lobby %s, something unexpected happened!")
				Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_BANNED:
					printerr("Failed joining lobby %s, you are banned from this lobby.")
				Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_LIMITED:
					printerr("Failed joining lobby %s, you cannot join due to having a limited account.")
				Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED:
					printerr("Failed joining lobby %s, this lobby is locked or disabled.")
				Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN:
					printerr("Failed joining lobby %s, this lobby is community locked.")
				Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU:
					printerr("Failed joining lobby %s, a user in the lobby has blocked you from joining.")
				Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER:
					printerr("Failed joining lobby %s, a user you have blocked is in the lobby.")
				Steam.ChatRoomEnterResponse.CHAT_ROOM_ENTER_RESPONSE_RATE_LIMIT_EXCEEDED:
					printerr("Failed joining lobby %s, you have exceeded the rate limit.")


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

@rpc("authority","call_local","reliable")
func start_game():
	get_tree().change_scene_to_packed(GAME)
	#Main.main_node._load_level()
