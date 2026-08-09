@tool
extends StaticBody3D

@onready var shine: OmniLight3D = $shine
@onready var collider: CollisionShape3D = $collider
@onready var aof: Area3D = $AOF
@onready var shockwave: MeshInstance3D = $Shockwave

@export_tool_button("test") var explo = func():explode_fx()

@export var ExplosionForce=5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint(): return
	await get_tree().physics_frame
	await get_tree().physics_frame
	for i in aof.get_overlapping_bodies():
		if i is RigidBody3D:
			var dir = global_position.direction_to(i.global_position)
			i.apply_central_impulse(dir*ExplosionForce)
	explode_fx()
	await get_tree().create_timer(5).timeout
	queue_free()

func explode_fx() -> void:
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(shine, "omni_range", 13, 0.25)
	tween.tween_property(shine, "light_energy", 9.5, 0.25)
	tween.tween_property(shockwave,"scale", Vector3.ONE * 8, 0.25)
	await get_tree().create_timer(.25).timeout
	tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(shockwave,"scale", Vector3.ZERO, 0.25)
	tween.tween_property(shine, "omni_range", 0, 0.25)
	$Bubbles.emitting = true
