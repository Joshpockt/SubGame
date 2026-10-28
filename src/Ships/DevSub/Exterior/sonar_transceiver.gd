extends Node3D
class_name SonarTransceiver


const BLIP = preload("uid://bwcfbfcwo1130")

@export var sonar_range := 100.0
@export var max_error_offset := 25.0

@export var near_color : Color = Color.GREEN
@export var far_color : Color = Color.AQUA

@export var passive_color : Color = Color.ORANGE

#FIXME HACK: Weak Ref
@onready var dev_exterior: SubExterior = $".."

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var sub_viewport: SubViewport = $SubViewport
@onready var multi_mesh_instance_2d: MultiMeshInstance2D = $SubViewport/MultiMeshInstance2D
@onready var camera_2d: Camera2D = $SubViewport/Camera2D
@onready var sonar_listener: SonarListener = $SonarListener

@onready var floor: CanvasLayer = $SubViewport/Floor
@onready var walls: CanvasLayer = $SubViewport/Walls
@onready var other: CanvasLayer = $SubViewport/Other


func _ready() -> void:
	ScreenManager.register_screen(sub_viewport, "SONAR")

var sonar_timer := INF
var passive_timer := INF
func _process(delta: float) -> void:
	sonar_timer += delta
	passive_timer += delta
	
	if sonar_timer >= 1.5:
		sonar_timer = 0.0
		sonar_floor()
		sonar_walls()
	
	if passive_timer >= 0.075:
		passive_timer = 0.0
		sonar_passive()
	
	var sub_pos := dev_exterior.global_position
	camera_2d.position = Vector2(sub_pos.x, sub_pos.z) * 1
	camera_2d.rotation = -dev_exterior.rotation.y
	

func sonar_floor():
	var sonar_precision = pow(2,6)
	for i in sonar_precision:
		#var direction := Vector3(randf_range(-1,1), randf_range(0.4,0.1) * [1,-1].pick_random(), randf_range(-1,1)).normalized()
		var direction := Vector3(randf_range(-1,1), randf_range(-0.2,-0.05), randf_range(-1,1)).normalized()
		ray_cast_3d.target_position = direction * sonar_range
		ray_cast_3d.force_raycast_update()
		if ray_cast_3d.is_colliding():
			var hit_pos := ray_cast_3d.get_collision_point()
			
			var distance := hit_pos.distance_to(dev_exterior.global_position)
			var distance_normalized := distance / sonar_range
			
			add_blip(hit_pos, near_color.lerp(far_color, distance_normalized) * Color(0.15,0.15,0.15), distance_normalized, floor)

# Swing
func sonar_walls():
	var sonar_precision = pow(2,6)
	@warning_ignore("integer_division")
	for i in sonar_precision:
		var angle : float = i / (sonar_precision / TAU)
		var direction := Vector3(sin(angle), 0.0, cos(angle)).normalized()
		ray_cast_3d.target_position = direction * sonar_range
		ray_cast_3d.force_raycast_update()
		if ray_cast_3d.is_colliding():
			var hit_pos := ray_cast_3d.get_collision_point()
			
			var distance := hit_pos.distance_to(dev_exterior.global_position)
			var distance_normalized := distance / sonar_range
			
			add_blip(hit_pos, near_color.lerp(far_color, distance_normalized), distance_normalized * max_error_offset, walls)


func sonar_passive():
	#print("ping")
	#print(sonar_listener.get_tracks())
	for track : SonarTrack in sonar_listener.get_tracks():
		#print(track.type)
		
		#var distance := hit_pos.distance_to(dev_exterior.global_position)
		#var distance := dev_exterior.global_position.distance_to(track.position)
		#var distance_normalized := distance / sonar_range
		
		var direction := dev_exterior.global_position.direction_to(track.position)
		direction = direction.rotated(Vector3.UP, randf_range(-0.1, 0.1))
		#add_blip((direction * distance * randf_range(0.0, 1.5)) + dev_exterior.global_position, passive_color, 10, other, 0.35)
		#var col = Color.BLACK.lerp(passive_color, track.strength / 100)
		var col : Color = Color.WHITE
		
		match track.type:
			SonarTrack.SonarType.GEOLOGIC:
				col = [Color.ORANGE, Color.ORANGE_RED, Color.RED, Color.GREEN, Color.AQUA].pick_random() * Color(0.3,0.3,0.3)
			SonarTrack.SonarType.TORPEDO:
				col = Color.ORANGE
			SonarTrack.SonarType.CREATURE:
				col = Color.RED
		
		#print(track.strength / 100)
		add_blip((direction * sonar_range * randf()) + dev_exterior.global_position, col, 5, other, 0.5)
		#add_blip((direction * sonar_range * randf()) + dev_exterior.global_position, col, 5, other, 0.35)
		#add_blip((direction * sonar_range * randf()) + dev_exterior.global_position, col, 5, other, 0.35)


func add_blip(pos: Vector3, color: Color, error: float, where: Node, duration: float = 3.0):
	var blip_instance : Blip = BLIP.instantiate()
	
	blip_instance.position = Vector2(pos.x, pos.z) + (Vector2(randf_range(-1,1), randf_range(-1,1)) * error)
	blip_instance.color = color
	blip_instance.duration = duration
	
	where.add_child(blip_instance)
