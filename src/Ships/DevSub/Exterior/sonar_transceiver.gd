extends Node3D
class_name SonarTransceiver


const BLIP = preload("uid://bwcfbfcwo1130")

@export var range := 100.0
@export var max_error_offset := 25.0

#FIXME HACK: Weak Ref
@onready var dev_exterior: SubExterior = $".."

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var sub_viewport: SubViewport = $SubViewport
@onready var multi_mesh_instance_2d: MultiMeshInstance2D = $SubViewport/MultiMeshInstance2D
@onready var camera_2d: Camera2D = $SubViewport/Camera2D

func _ready() -> void:
	ScreenManager.register_screen(sub_viewport, "SONAR")

var sonar_timer := INF
func _process(delta: float) -> void:
	sonar_timer += delta
	
	if sonar_timer >= 1.5:
		sonar_timer = 0.0
		sonar_pulse2()
		sonar_pulse()
	
	var sub_pos := dev_exterior.global_position
	camera_2d.position = Vector2(sub_pos.x, sub_pos.z) * 1
	camera_2d.rotation = -dev_exterior.rotation.y
	

func sonar_pulse2():
	print("Ping")
	var sonar_precision = pow(2,6)
	@warning_ignore("integer_division")
	for i in sonar_precision:
		#var direction := Vector3(randf_range(-1,1), randf_range(0.4,0.1) * [1,-1].pick_random(), randf_range(-1,1)).normalized()
		var direction := Vector3(randf_range(-1,1), randf_range(-0.2,0.0), randf_range(-1,1)).normalized()
		ray_cast_3d.target_position = direction * range
		ray_cast_3d.force_raycast_update()
		if ray_cast_3d.is_colliding():
			var blip_instance : Blip = BLIP.instantiate()
			var hit_pos := ray_cast_3d.get_collision_point()
			
			var distance := hit_pos.distance_to(dev_exterior.global_position)
			var distance_normalized := distance / range
			#var vertical_distance : float = abs(hit_pos.y - dev_exterior.global_position.y)
			#var vertical_distance_normalized = 0.15
			
			#FIXME: Make this easier to look at.
			blip_instance.position = Vector2(hit_pos.x, hit_pos.z) + (Vector2(randf_range(-1,1), randf_range(-1,1)) * max_error_offset * distance_normalized)
			blip_instance.color = blip_instance.color.lerp(blip_instance.color_far, distance_normalized)
			blip_instance.color *= 0.3
			
			sub_viewport.add_child(blip_instance)

# Swing
func sonar_pulse():
	print("Ping")
	var sonar_precision = pow(2,6)
	@warning_ignore("integer_division")
	for i in sonar_precision:
		var angle : float = i / (sonar_precision / TAU)
		var direction := Vector3(sin(angle), 0.0, cos(angle)).normalized()
		ray_cast_3d.target_position = direction * range
		ray_cast_3d.force_raycast_update()
		if ray_cast_3d.is_colliding():
			var blip_instance : Blip = BLIP.instantiate()
			var hit_pos := ray_cast_3d.get_collision_point()
			
			var distance := hit_pos.distance_to(dev_exterior.global_position)
			var distance_normalized := distance / range
			
			#FIXME: Make this easier to look at.
			blip_instance.position = Vector2(hit_pos.x, hit_pos.z) + (Vector2(randf_range(-1,1), randf_range(-1,1)) * max_error_offset * distance_normalized)
			blip_instance.color = blip_instance.color.lerp(blip_instance.color_far, distance_normalized)
			
			sub_viewport.add_child(blip_instance)
