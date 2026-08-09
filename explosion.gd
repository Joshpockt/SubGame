@tool
extends Node3D

@onready var shine: OmniLight3D = $shine
@onready var aof: Area3D = $AOF
@onready var shockwave: MeshInstance3D = $Shockwave

@export_tool_button("test") var explo = func():explode_fx()

@export var ExplosionForce=5


func _ready() -> void:
	if Engine.is_editor_hint(): return
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	for i in aof.get_overlapping_bodies():
		if i is RigidBody3D:
			var dir = global_position.direction_to(i.global_position)
			#i.apply_central_impulse(dir*ExplosionForce)
			i.apply_impulse(dir*ExplosionForce,i.to_local(global_position))
	explode_fx()
	await get_tree().create_timer(5).timeout
	queue_free()

func explode_fx() -> void:
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(shine, "omni_range", ExplosionForce+8, 0.25)
	tween.tween_property(shine, "light_energy", ExplosionForce+4.5, 0.25)
	tween.tween_property(shockwave,"scale", Vector3.ONE * (ExplosionForce+3), 0.25)
	
	await get_tree().create_timer(.25).timeout
	
	tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(shockwave,"scale", Vector3.ZERO, 0.25)
	tween.tween_property(shine, "omni_range", 0, 0.25)
	$Bubbles.emitting = true
