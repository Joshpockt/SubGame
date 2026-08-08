extends StaticBody3D

@onready var shine: OmniLight3D = $shine
@onready var collider: CollisionShape3D = $collider
@onready var aof: Area3D = $AOF

@export var ExplosionForce=50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	for i in aof.get_overlapping_bodies():
		if i is RigidBody3D:
			var dir = global_position.direction_to(i.global_position)
			i.apply_central_impulse(dir*ExplosionForce)
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(shine, "omni_range", 13, 0.3)
	tween.tween_property(shine, "light_energy", 9.5, 0.3)
	tween.tween_property(collider, "scale", Vector3.ONE*4.5, 0.3)
	await get_tree().create_timer(.35).timeout
	tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(shine, "omni_range", 0, 0.3)
	tween.tween_property(collider, "scale", Vector3.ZERO, 0.3)
	await get_tree().create_timer(.35).timeout
	queue_free()
