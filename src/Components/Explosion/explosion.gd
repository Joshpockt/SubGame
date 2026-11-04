extends Node3D
class_name Explosion

const BASE_EXPLOSION_FORCE = 100.0
const BASE_EXPLOSION_DAMAGE := 1.0

var explosion_strength := 10.0

@onready var area_3d: Area3D = $Area3D

func _ready() -> void:
	scale = Vector3.ONE * explosion_strength

func _physics_process(_delta: float) -> void:
	await get_tree().physics_frame
	#print("boom")
	var base_force := explosion_strength * BASE_EXPLOSION_FORCE
	for body in area_3d.get_overlapping_bodies():
		if body is RigidBody3D:
			var force : float =  max(0.0, lerp(base_force, 0.0, max(0.0, global_position.distance_to(body.global_position) / (explosion_strength * 3))))
			#print(force)
			#print(global_position.distance_to(body.global_position))
			body.apply_central_impulse(
				global_position.direction_to(body.global_position) * force
				)
	queue_free()
	
	var base_damage := BASE_EXPLOSION_DAMAGE * explosion_strength
	for area in area_3d.get_overlapping_areas():
		if area is Hitbox3D:
			#print(area)
			var attack_data := AttackData.new()
			attack_data.damage = max(0.0, lerp(base_damage, 0.0, max(0.0, global_position.distance_to(area.global_position) / explosion_strength)))
			area.hit(attack_data)
	#process_mode = Node.PROCESS_MODE_DISABLED
