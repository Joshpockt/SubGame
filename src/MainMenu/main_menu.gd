extends Control

const PLAYER_LABEL = preload("uid://bbkc5a3fb7cn7")
const DEFAULT_ADDRESS := "127.0.0.1"
const PORT := 25565
const GAME = preload("uid://dgvqg2yagkuep")


@onready var starting_screen: Control = %StartingScreen
@onready var lobby: Control = %Lobby

@onready var host_button: Button = %HostButton
@onready var join_button: Button = %JoinButton
@onready var address: LineEdit = %Address

@onready var lobby_player_list: VBoxContainer = %LobbyPlayerList
@onready var start_game_button: Button = %StartGame


func _ready() -> void:
	host_button.pressed.connect(_host_pressed)
	join_button.pressed.connect(_join_pressed)
	
	starting_screen.show()
	lobby.hide()
	
	var f = func(id:int):
		add_player_label(str(id))
	multiplayer.peer_connected.connect(f)
	var f2 = func(id:int):
		remove_player_label(str(id))
	multiplayer.peer_disconnected.connect(f2)
	var f3 = func():
		rpc("start_game")
	start_game_button.pressed.connect(f3)


func _host_pressed():
	print("Attempting to create a server...")
	var error = EnetNetworking.create_server()
	#print(error_string(error))
	if error == OK:
		print("Server successfully created!")
		starting_screen.hide()
		lobby.show()
		add_player_label(str(1))
		start_game_button.show()


func _join_pressed():
	var addr : String = DEFAULT_ADDRESS if address.text == "" else address.text
	print("Attemping to join \"%s\"" % addr)
	var error = EnetNetworking.join_server(addr)
	#print(error_string(error))
	if error == OK:
		print("Sucessfully joined \"%s\"" % addr)
		starting_screen.hide()
		lobby.show()
		add_player_label(str(multiplayer.get_unique_id()))
		start_game_button.hide()


func add_player_label(player_name: String):
	var label_instance : PlayerLobbyLabel = PLAYER_LABEL.instantiate()
	lobby_player_list.add_child(label_instance)
	label_instance.label.text = player_name


func remove_player_label(player_name: String):
	for child : PlayerLobbyLabel in lobby_player_list.get_children():
		if child.label.text == player_name:
			child.queue_free()
			return


@rpc("authority","call_local","reliable")
func start_game():
	get_tree().change_scene_to_packed(GAME)
	#Main.main_node._load_level()
