extends Node3D
class_name SubWeaponController

@warning_ignore("unused_signal")
signal on_shot

@export var max_ammo := 1
@export var plus_one := false

@export var projectile_scene : PackedScene

@export_group("Nodes")
@export var projectile_spawn_marker : Node3D
@export var exterior : SubExterior


var ammo := 0:
	set(value):
		ammo = value
		print(ammo)


func shoot():
	if ammo > 0:
		print("shoot")
		ammo -= 1
		var projectile_instance : Node3D = projectile_scene.instantiate()
		exterior.add_sibling(projectile_instance)
		projectile_instance.global_transform = projectile_spawn_marker.global_transform


@rpc("any_peer", "call_remote", "reliable")
func sync_shoot():
	pass

@rpc("any_peer", "call_remote", "reliable")
func sync_ammo():
	pass
