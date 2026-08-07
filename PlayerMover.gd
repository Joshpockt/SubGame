extends CharacterBody3D

@onready var syncronizer: MultiplayerSynchronizer = $"../Syncronizer"
@onready var camera: Camera3D = $"../CameraHolder/Camera"
@onready var player: Node3D = $".."

var tabout = false;
@onready var camera_offset: Node3D = $CameraOffset
@onready var camera_holder: Node3D = $"../CameraHolder"

var mouseX = 0;
var mouseY = 0;
const sensitivity = 10;
const SPEED = 5.0
const JUMP_VELOCITY = 4.5


var ExternalCameraHook=null

@export var posLerpTo=Vector3.ZERO;
@export var rotLerpTo=Vector3.ZERO;



func HullShaken():
	camera_offset._custom_shake(2, 0.1)

func _ready() -> void:
	await get_tree().process_frame
	if !syncronizer.is_multiplayer_authority():
		$"../UI".queue_free()
		$"../CameraHolder/Camera".queue_free()
		set_collision_mask_value(2,true)
		set_collision_mask_value(1,false)
		set_collision_layer_value(2,true)
		set_collision_layer_value(1,false)
		set_physics_process(false)
		set_process_input(false)
	else:
		$Render.hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
		player.username=Steam.getPersonaName()
		player.submarine.SubTookDamage.connect(HullShaken)
		
		
func cameraMovments(delta: float):
	if ExternalCameraHook == null:
		Utils.SnapTo(camera_holder,camera_offset)
	else:
		Utils.LerpTo(camera_holder,ExternalCameraHook,delta*10)

		

func updateTabout():
	if tabout:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
		$"../UI/Crosshair".hide()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
		$"../UI/Crosshair".show()

func _input(event: InputEvent) -> void:
	if !syncronizer.is_multiplayer_authority(): return;
	if event is InputEventMouseMotion && !tabout:
		camera_offset.rotation_degrees.x += event.screen_relative.y/-sensitivity;
		camera_offset.rotation_degrees.x = clamp(camera_offset.rotation_degrees.x,-89,89)
		rotation_degrees.y += event.screen_relative.x/-sensitivity;
	else:
		if Input.is_action_just_pressed("tab_out"):
			tabout=!tabout;
			updateTabout()

func _process(delta: float) -> void:
	$Render/display_name.text=player.username
	if syncronizer.is_multiplayer_authority():
		
		cameraMovments(delta)
		if global_position.distance_to(posLerpTo) > .1:
			posLerpTo=global_position
		#if global_rotation.distance_to(rotLerpTo) > .1:
			#print("updating rotation")
			#rotLerpTo=global_rotation
	else:
		pass
		global_position=global_position.lerp(posLerpTo,15*delta)
		#global_rotation=global_rotation.lerp(rotLerpTo,15*delta)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if tabout:return;
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
