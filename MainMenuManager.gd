extends Node

@onready var host_button: Button = $MainMenu/CenterContainer/VBoxContainer/HostButton
@onready var join_button: Button = $MainMenu/CenterContainer/VBoxContainer/JoinButton
@onready var player_base: Label = $MainMenu/CenterContainer/InLobby/Players/PlayerBase
@onready var players: VBoxContainer = $MainMenu/CenterContainer/InLobby/Players

var interior = preload("res://interior_world.tscn")

var peer : SteamMultiplayerPeer;
var lobby_id;
var config = ConfigFile.new()
var isHost=false

@rpc("any_peer","call_local","reliable")
func addPlayerLabel(name:String):
	var label = player_base.duplicate()
	players.add_child(label)
	label.show()
	label.text=name

@warning_ignore("shadowed_variable", "unused_parameter")
func join_request(lobby_id:int,steam_id:int):
	Steam.joinLobby(lobby_id)

func _on_player_connected(id: int):
	print("player connected, "+str(id))
	rpc_id(id,"addPlayerLabel",Steam.getPersonaName())
	
	

@warning_ignore("unused_parameter", "shadowed_variable")
func _on_lobby_joined(lobby_id:int,permissions:int,locked:bool,response:int):
	Steam.setLobbyData(lobby_id,"subgame","gameonjerkoff")
	if isHost: return
	self.lobby_id=lobby_id
	peer= SteamMultiplayerPeer.new()
	peer.server_relay=true
	$MainMenu/CenterContainer/VBoxContainer.hide()
	$MainMenu/CenterContainer/InLobby.show()
	peer.create_client(Steam.getLobbyOwner(lobby_id))
	multiplayer.multiplayer_peer=peer
	multiplayer.peer_connected.connect(_on_player_connected)
#	multiplayer.peer_disconnected.connect(_on_player_disconnect)
	await multiplayer.connected_to_server

	addPlayerLabel(Steam.getPersonaName())
	
	
func _on_lobby_created(result:int,lobby_id:int):
	if result == Steam.Result.RESULT_OK:
		isHost=true
		print("hosting")

		self.lobby_id=lobby_id
		$MainMenu/CenterContainer/VBoxContainer.hide()
		$MainMenu/CenterContainer/InLobby.show()
		$MainMenu/CenterContainer/InLobby/Start.show()
		$MainMenu/CenterContainer/InLobby/Debug.show()
		peer = SteamMultiplayerPeer.new()
		peer.server_relay=true
		peer.create_host()
		multiplayer.multiplayer_peer=peer
		addPlayerLabel(Steam.getPersonaName())
		multiplayer.peer_connected.connect(_on_player_connected)
		#Steam.setLobbyData(lobby_id,"date",data.date)
		#Steam.setLobbyData(lobby_id,"name",data.displayname)
		#Steam.setLobbyData(lobby_id,"ver",data.gameversion)
		#Steam.setLobbyData(lobby_id,"usr",Steam.getPersonaName())

@rpc("authority","call_local","reliable")
func EnterTesting():
	var game = load("res://debug_scene.tscn").instantiate()
	get_tree().root.add_child(game)
	queue_free()


@rpc("authority","call_local","reliable")
func StartGame():
	var game = interior.instantiate()
	get_tree().root.add_child(game)
	queue_free()

func HostStartGame():
	rpc("StartGame")
	
func HostDebugGame():
	rpc("EnterTesting")

func create_server():
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.createLobby(Steam.LobbyType.LOBBY_TYPE_PUBLIC,8)
	multiplayer.multiplayer_peer=peer
	
	print("attemtping")



func _ready() -> void:
	print("Steam initialized: ",Steam.steamInit(480,true))
	Steam.initRelayNetworkAccess()
	host_button.pressed.connect(create_server)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.join_requested.connect(join_request)
	Steam.lobby_match_list.connect(lobby_match_list)
	$MainMenu/CenterContainer/VBoxContainer/JoinButton.pressed.connect(attemptJoin)
	$MainMenu/CenterContainer/InLobby/Start.pressed.connect(HostStartGame)
	$MainMenu/CenterContainer/InLobby/Debug.pressed.connect(HostDebugGame)


func attemptJoin():
	Steam.addRequestLobbyListStringFilter("subgame","gameonjerkoff", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.addRequestLobbyListFilterSlotsAvailable(1)
	Steam.addRequestLobbyListDistanceFilter(Steam.LobbyDistanceFilter.LOBBY_DISTANCE_FILTER_DEFAULT)
	Steam.requestLobbyList()

func lobby_match_list(lobby_ids):
	print(lobby_ids)
	for lobby_id in lobby_ids:
		Steam.joinLobby(lobby_id)
		break

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
