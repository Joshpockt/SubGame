extends Node

@onready var spawnpoint: Node3D = $Spawnpoint
var localplayer;
var avatar = preload("res://player.tscn")
var firstServerId;
# Called when the node enters the scene tree for the first time.

func player_leaves(id: int):
	for i in $Players.get_children():
		if i.name.contains(str(id)):
			i.queue_free()


func _ready() -> void:
	multiplayer.peer_disconnected.connect(player_leaves)
	self.set_multiplayer_authority(1)
	localplayer = avatar.instantiate()
	add_child(localplayer)
	localplayer.name=str(multiplayer.get_unique_id())
	localplayer.set_multiplayer_authority(multiplayer.get_unique_id())
	localplayer.find_child("Syncronizer").set_multiplayer_authority(multiplayer.get_unique_id())
	for i in multiplayer.get_peers():
		var plr = avatar.instantiate()
		add_child(plr)
		plr.set_multiplayer_authority(i)
		plr.find_child("Syncronizer").set_multiplayer_authority(i)
		plr.name=str(i)
		plr.find_child("Mover").global_position+=Vector3(0,5,0)

	
