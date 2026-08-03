extends Node

@onready var host_button: Button = $MainMenu/CenterContainer/VBoxContainer/HostButton
@onready var join_button: Button = $MainMenu/CenterContainer/VBoxContainer/JoinButton
@onready var player_base: Label = $MainMenu/CenterContainer/InLobby/Players/PlayerBase
@onready var players: VBoxContainer = $MainMenu/CenterContainer/InLobby/Players

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


func _on_player_connected(id: int):
	print("player connected, "+str(id))
	rpc("addPlayerLabel",Steam.getPersonaName())
	
func _on_lobby_created(result:int,lobby_id:int):
	if result == Steam.Result.RESULT_OK:
		isHost=true
		print("hosting")
		self.lobby_id=lobby_id
		$MainMenu/CenterContainer/VBoxContainer.hide()
		$MainMenu/CenterContainer/InLobby.show()
		peer = SteamMultiplayerPeer.new()
		peer.server_relay=true
		peer.create_host()
		multiplayer.multiplayer_peer=peer
		addPlayerLabel(Steam.getPersonaName())
		multiplayer.peer_connected.connect(_on_player_connected)
		#multiplayer.peer_disconnected.connect(_on_player_disconnect)
		#$Menu.hide();
		#$InRoom.show();
		#$InRoom/Host.show()
		#add_player_to_list(ClientData.username,multiplayer.get_unique_id())


func create_server():
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.createLobby(Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY,16)
	print("attemtping")



func _ready() -> void:
	print("Steam initialized: ",Steam.steamInit(480,true))
	Steam.initRelayNetworkAccess()
	host_button.pressed.connect(create_server)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
