extends Node3D
class_name SonarTransceiver


const BLIP = preload("uid://bwcfbfcwo1130")

@export var range := 200.0

#FIXME HACK: Weak Ref
@onready var dev_exterior: SubExterior = $".."

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var sub_viewport: SubViewport = $SubViewport
@onready var multi_mesh_instance_2d: MultiMeshInstance2D = $SubViewport/MultiMeshInstance2D
@onready var camera_2d: Camera2D = $SubViewport/Camera2D

func _ready() -> void:
	ScreenManager.register_screen(sub_viewport, "SONAR")

var sonar_timer := 0.0
func _process(delta: float) -> void:
	sonar_timer += delta
	
	if sonar_timer >= 2.0:
		sonar_timer = 0.0
		sonar_pulse()
	
	var sub_pos := dev_exterior.global_position
	camera_2d.position = Vector2(sub_pos.x, sub_pos.z) * 1
	camera_2d.rotation = -dev_exterior.rotation.y
	


func sonar_pulse():
	print("Ping")
	var sonar_precision = pow(2,6)
	@warning_ignore("integer_division")
	for i in sonar_precision:
		var angle : float = i / (sonar_precision / TAU)
		# We add a random number to make the rays feel less "stiff"
		var direction := Vector3(sin(angle + randf() * 0.1), 0.0, cos(angle + randf() * 0.1)).normalized()
		ray_cast_3d.target_position = direction * range
		ray_cast_3d.force_raycast_update()
		if ray_cast_3d.is_colliding():
			var blip_instance : Node2D = BLIP.instantiate()
			var hit_pos := ray_cast_3d.get_collision_point()
			
			var distance := hit_pos.distance_to(dev_exterior.global_position)
			
			sub_viewport.add_child(blip_instance)
			blip_instance.position = Vector2(hit_pos.x, hit_pos.z) + (Vector2(randf(), randf()) * 50 * (distance / range))
