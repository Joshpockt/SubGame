@tool
extends Marker3D
class_name IKThing

@export var target : Marker3D
@export var buddy : IKThing
@export var distance := 1.0
@export var step_time := 0.5

var tween : Tween
var down_tween : Tween
var is_stepping := false

signal step_done

func step():
	is_stepping = true
	if tween != null: tween.kill()
	if down_tween != null: down_tween.kill()
	
	var mid_pos = to_global(to_local(target.global_position) * 0.5) + (Vector3.UP * 0.15)
	
	tween = get_tree().create_tween()
	down_tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(target, "global_position", mid_pos, step_time * 0.5)
	
	down_tween.set_ease(Tween.EASE_OUT)
	down_tween.set_trans(Tween.TRANS_SINE)
	down_tween.tween_await(tween.finished)
	down_tween.tween_property(target, "global_position", global_position, step_time * 0.5)
	
	tween.finished.connect(func(): is_stepping = false; step_done.emit())


func _process(delta: float) -> void:
	if is_stepping: return
	#if buddy:
		#if buddy.is_stepping: return
	if target.global_position.distance_to(global_position)  > distance:
		# Force Step
		step()
