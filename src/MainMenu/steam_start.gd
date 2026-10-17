extends Control

const STEAM_LOBBY_LABEL = preload("uid://buku4xyly0j33")
const PLAYER_LABEL = preload("uid://bbkc5a3fb7cn7")

@onready var lobbies: VBoxContainer = %Lobbies
@onready var lobby_player_list: VBoxContainer = %LobbyPlayerList

@onready var starting_screen: Control = %StartingScreen
@onready var lobby_list: Control = %LobbyList
@onready var lobby: Control = %Lobby

@onready var host_button: Button = %HostButton
@onready var join_button: Button = %JoinButton


func _ready() -> void:
	hide_all()
	starting_screen.show()
	
	SteamNetworking.init_steam()
	host_button.pressed.connect(_host_pressed)
	join_button.pressed.connect(_join_pressed)
	Steam.lobby_match_list.connect(_on_lobby_list_ready)
	_refresh_lobbies()
	
	var f = func(id:int):
		add_player_label(str(id))
	multiplayer.peer_connected.connect(f)


func _refresh_lobbies():
	Steam.requestLobbyList()


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
	var error = SteamNetworking.join_server(lobby_id)
	if error == OK:
		add_player_label(str(multiplayer.get_unique_id()))
		hide_all()
		lobby.show()

func _host_pressed():
	SteamNetworking.create_server()
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
	
	for lobby in lobby_ids:
		var response = Steam.getLobbyData(lobby, "roob")
		if response != "true": continue
		
		var lobby_label : LobbyLabel = STEAM_LOBBY_LABEL.instantiate()
		lobbies.add_child(lobby_label)
		lobby_label.label.text = Steam.getLobbyData(lobby, "name")
