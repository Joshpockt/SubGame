extends Node
class_name SubInterior

@onready var spawnpoint: Node3D = $Spawnpoint
var localplayer;
var avatar = preload("res://player.tscn")
var firstServerId;
var Players:Dictionary
#@onready var sub_exterior: RigidBody3D = $ExteriorViewport/ExteriorWorld/SubExterior


func player_leaves(id: int):
	for i in $Players.get_children():
		if i.name.contains(str(id)):
			i.queue_free()

func test():
	pass

func _ready() -> void:
	multiplayer.peer_disconnected.connect(player_leaves)
	self.set_multiplayer_authority(1)
	localplayer = avatar.instantiate()
	add_child(localplayer)
	localplayer.name = str(multiplayer.get_unique_id())
	localplayer.set_multiplayer_authority(multiplayer.get_unique_id())
	localplayer.find_child("Syncronizer").set_multiplayer_authority(multiplayer.get_unique_id())
	#localplayer.submarine = sub_exterior
	Players[multiplayer.get_unique_id()]=localplayer
	#$Ship.localplayer=localplayer
	for i in multiplayer.get_peers():
		var player_instance = avatar.instantiate()
		add_child(player_instance)
		player_instance.set_multiplayer_authority(i)
		player_instance.find_child("Syncronizer").set_multiplayer_authority(i)
		player_instance.name=str(i)
		player_instance.find_child("Mover").global_position+=Vector3(0,5,0)
		Players[i]=player_instance

	
