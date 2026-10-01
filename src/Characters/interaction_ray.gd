extends RayCast3D

var last_interaction_area : InteractionArea = null
var crosshair_tween : Tween
var t := 0.0

@onready var player: Player = $"../.."
@onready var crosshair: TextureRect = $"../../CenterContainer/Crosshair"


func _process(delta: float) -> void:
	if player.can_move == false: return
	
	var id = multiplayer.get_unique_id()
	var area = get_collider()
	
	if area == null:
		# If area does not exist then flush the previous one (if that exists.)
		flush_last_interaction_area(id)
		return
	
	if area is InteractionArea:
		if area != last_interaction_area:
			flush_last_interaction_area(id)
		
		# If we are looking at an area then we observe it
		area.observe(id)
		if !area.disable_interaction:
			open_crosshair()
		# If we have inputs then handle them
		if Input.is_action_just_pressed("interact"):
				last_interaction_area = area
				#area.inteact(id)
				area.start_interaction(id)
		elif Input.is_action_just_released("interact"):
			flush_last_interaction_area(id)
		elif Input.is_action_pressed("interact"):
			if last_interaction_area == null:
				if area.allow_swipe == true:
					last_interaction_area = area
					#area.inteact(id)
					area.start_interaction(id)
		
		# If last_interaction_area has not been flushed, then tick its interaction time.
		if last_interaction_area != null and last_interaction_area.interaction_time != 0.0 and !area.disable_interaction:
			crosshair.material.set("shader_parameter/progress", last_interaction_area.interaction_progress)
			t += delta
			last_interaction_area.current_interaction_time = t
			if t >= last_interaction_area.interaction_time:
				last_interaction_area.inteact(id)
				flush_last_interaction_area(id)
		if last_interaction_area != null and last_interaction_area.interaction_time == 0.0:
			last_interaction_area.inteact(id)
			flush_last_interaction_area(id)

# helper function
func flush_last_interaction_area(id: int):
	close_crosshair()
	crosshair.material.set("shader_parameter/progress", 1)
	if last_interaction_area != null:
		last_interaction_area.stop_interaction(id)
		last_interaction_area.current_interaction_time = 0.0
		last_interaction_area = null
		t = 0.0

func open_crosshair():
	if crosshair_tween != null:
		crosshair_tween.kill()
	
	crosshair_tween = get_tree().create_tween()
	crosshair_tween.set_parallel(true)
	
	crosshair_tween.tween_property(crosshair.material, "shader_parameter/circleSize", 0.5, 0.05)
	crosshair_tween.tween_property(crosshair.material, "shader_parameter/hollowSize", 0.3, 0.05)

func close_crosshair():
	if crosshair_tween != null:
		crosshair_tween.kill()
	
	crosshair_tween = get_tree().create_tween()
	crosshair_tween.set_parallel(true)
	
	crosshair_tween.tween_property(crosshair.material, "shader_parameter/circleSize", 0.3, 0.05)
	crosshair_tween.tween_property(crosshair.material, "shader_parameter/hollowSize", 0.0, 0.05)
