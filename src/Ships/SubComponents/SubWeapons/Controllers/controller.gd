extends Node3D
class_name SubWeaponController

# This class is held together by hotglue and dreams.

@warning_ignore("unused_signal")
#signal on_shot

@export var max_ammo := 1

@export var projectile_scene : PackedScene

@export_group("Nodes")
@export var projectile_spawn_marker : Node3D
@export var exterior : SubExterior


var ammo := 0:
	set(value):
		ammo = clamp(value, 0, max_ammo)
		#sync_ammo.rpc(ammo)

var fully_loaded := false:
	get():
		return ammo == max_ammo


func add_ammo(ammount):
	ammo = clamp(ammo + ammount, 0, max_ammo)
	sync_ammo.rpc(ammo)


func shoot():
	sync_shoot.rpc()


@rpc("any_peer", "call_local", "reliable")
func sync_shoot() -> void:
	print(ammo)
	if ammo > 0:
		ammo -= 1
		var projectile_instance : Node3D = projectile_scene.instantiate()
		exterior.add_sibling(projectile_instance)
		projectile_instance.global_transform = projectile_spawn_marker.global_transform
		if projectile_instance is RigidBody3D:
			projectile_instance.linear_velocity = exterior.linear_velocity


@rpc("any_peer", "call_remote", "reliable")
func sync_ammo(new_ammo: int) -> void:
	ammo = new_ammo
