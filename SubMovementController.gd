extends RigidBody3D

const SPEED = 5.0
const ROTATION_SPEED=5.0
const VERTICAL_SPEED = 3
@onready var front_view_camera: Camera3D = $FrontView/Camera
@onready var front_view_anchor: Node3D = $FrontViewAnchor

@onready var syncronizer: MultiplayerSynchronizer = $Syncronizer

var inUse=false
var hasPower=true

func _process(delta: float) -> void:
	Utils.SnapTo(front_view_camera,front_view_anchor)

func _physics_process(delta: float) -> void:
	if !syncronizer.is_multiplayer_authority() || !inUse || !hasPower:return
	var movement_dir := Input.get_vector("descend", "rise", "ui_up", "ui_down")
	var rotation_dir := Input.get_vector("ui_right", "ui_left", "ui_up", "ui_down")
	var movement := (transform.basis * Vector3(0, movement_dir.x, movement_dir.y)).normalized()
	var rotation := (transform.basis * Vector3(0, rotation_dir.x, 0)).normalized()
	apply_central_force(movement*SPEED)
	apply_torque(rotation*ROTATION_SPEED)
