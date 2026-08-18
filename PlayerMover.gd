extends CharacterBody3D
class_name Player

@onready var syncronizer: MultiplayerSynchronizer = $Syncronizer
@onready var camera: Camera3D = $CameraHolder/Camera

var tabout := false;
@onready var camera_offset: Node3D = $CameraOffset
@onready var camera_holder: Node3D = $CameraHolder
@onready var tree: AnimationTree = $Tree

var mouseX := 0;
var mouseY := 0;
var username := ""
const sensitivity = 10;
const SPEED = 4.0
const JUMP_VELOCITY = 4.5


var external_camera_hook : Node3D = null
@export_storage var posLerpTo := Vector3.ZERO;
@export_storage var rotLerpTo := Vector3.ZERO;
@export_storage var input_dir_anims: Vector2

var input_Lerp:Vector2

func HullShaken() -> void:
	camera_offset._custom_shake(2, 0.1)

@onready var render: Node3D = $Render/Model

var currentEmote := ""
@onready var animation_player: AnimationPlayer = $Render/Model/AnimationPlayer

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
		render.hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
		username = Steam.getPersonaName()
		GameEventBus.hull_hit.connect(HullShaken)


func handle_camera(_delta: float) -> void:
	if external_camera_hook == null:
		Utils.snap_to(camera_holder,camera_offset)
	else:
		Utils.snap_to(camera_holder,external_camera_hook)


func updateTabout() -> void:
	if tabout:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
		$UI/Crosshair.hide()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
		$UI/Crosshair.show()


@rpc("authority","call_local","reliable")
func PlayEmote(animname: String) -> void:
	if multiplayer.get_remote_sender_id() == multiplayer.get_unique_id():
		render.show()
		camera_offset.position.z=1.6
	tree.active=false
	animation_player.play("character/"+animname)
	currentEmote = animname
	render.position.y=-1


@rpc("authority","call_local","reliable")
func StopEmotes() -> void:
	camera_offset.position.z=0
	currentEmote=""
	tree.active=true
	animation_player.stop(false)
	if multiplayer.get_remote_sender_id() == multiplayer.get_unique_id():
		render.hide()
		camera_offset.position.z=0


func _input(event: InputEvent) -> void:
	if !syncronizer.is_multiplayer_authority(): return;
	if event is InputEventMouseMotion && !tabout:
		camera_offset.rotation_degrees.x += event.screen_relative.y/-sensitivity;
		camera_offset.rotation_degrees.x = clamp(camera_offset.rotation_degrees.x,-89,89)
		rotation_degrees.y += event.screen_relative.x/-sensitivity;
	else:
		if Input.is_action_just_pressed("emote1"):
			rpc("PlayEmote","emote1")
		if Input.is_action_just_pressed("emote2"):
			rpc("PlayEmote","emote2")
		if Input.is_action_just_pressed("emote3"):
			rpc("PlayEmote","emote3")
		if Input.is_action_just_pressed("emote4"):
			rpc("PlayEmote","emote4")
		if Input.is_action_just_pressed("emote5"):
			rpc("PlayEmote","emote5")
		if Input.is_action_just_pressed("emote6"):
			rpc("PlayEmote","emote6")
		if Input.is_action_just_pressed("emote7"):
			rpc("PlayEmote","emote7")
		if Input.is_action_just_pressed("tab_out"):
			tabout=!tabout;
			updateTabout()


func _process(delta: float) -> void:
	if !currentEmote.is_empty():
		render.position.y=-1
		render.rotation_degrees.y=180
		if input_dir_anims.length() != 0 && syncronizer.is_multiplayer_authority():
			rpc("StopEmotes")
		if animation_player.current_animation != "character/"+currentEmote:
			currentEmote=""
			tree.active=true
			if syncronizer.is_multiplayer_authority():
				render.hide()
				camera_offset.position.z=0


	else:
		render.rotation.y=0
		render.position.y=0
	$Render/display_name.text = username
	if syncronizer.is_multiplayer_authority():
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		if input_dir_anims != input_dir:
			input_dir_anims=input_dir
		input_Lerp=input_Lerp.lerp(input_dir,8*delta)
		tree.set("parameters/MainTree/blend_position", input_Lerp)
		if tabout:
			input_dir=Vector2.ZERO
			input_dir_anims=Vector2.ZERO
		handle_camera(delta)
		if global_position.distance_to(posLerpTo) > .1:
			posLerpTo=global_position
		#if global_rotation.distance_to(rotLerpTo) > .1:
			#print("updating rotation")
			#rotLerpTo=global_rotation
	else:
		input_Lerp=input_Lerp.lerp(input_dir_anims,8*delta)
		tree.set("parameters/MainTree/blend_position", input_Lerp)
		global_position=global_position.lerp(posLerpTo,15*delta)
		#global_rotation=global_rotation.lerp(rotLerpTo,15*delta)


func _physics_process(delta: float) -> void:
	if tabout:return;
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
