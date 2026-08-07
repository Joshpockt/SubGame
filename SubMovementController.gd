extends RigidBody3D

const SPEED = 5.0
const ROTATION_SPEED=5.0
const VERTICAL_SPEED = 3
@onready var front_view_camera: Camera3D = $FrontView/Camera
@onready var front_view_anchor: Node3D = $FrontViewAnchor
@onready var bumper: Area3D = $Bumper
@onready var collider: CollisionShape3D = $Bumper/Collider

var shakeCooldown=0.0
var lastMagnitude=0.0
var lastlastMagnitdue=0.0
var Damage=0
var isColliding=false
var currentCollisionPoint=Vector3.ZERO

signal SubTookDamage

@onready var syncronizer: MultiplayerSynchronizer = $Syncronizer

var inUse=false
var hasPower=true

@rpc("authority","call_local","reliable")
func SubCollides():
	Damage+=1
	print("kadunk")
	shakeCooldown=1.0
	SubTookDamage.emit()
	
	


func _process(delta: float) -> void:
	Utils.SnapTo(front_view_camera,front_view_anchor)
	shakeCooldown-=delta

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	isColliding=state.get_contact_count()!=0
	if isColliding:
		currentCollisionPoint=to_local(state.get_contact_collider_position(0))
		
	
	
func _physics_process(delta: float) -> void:
	if isColliding && syncronizer.is_multiplayer_authority():
		if shakeCooldown <= 0 && lastlastMagnitdue > 1.8:
			rpc("SubCollides")
	lastlastMagnitdue=lastMagnitude
	lastMagnitude=(linear_velocity.length()+angular_velocity.length())
	if !syncronizer.is_multiplayer_authority() || !inUse || !hasPower:return
	var movement_dir := Input.get_vector("descend", "rise", "ui_up", "ui_down")
	var rotation_dir := Input.get_vector("ui_right", "ui_left", "ui_up", "ui_down")
	var movement := (transform.basis * Vector3(0, movement_dir.x, movement_dir.y)).normalized()
	var rotation := (transform.basis * Vector3(0, rotation_dir.x, 0)).normalized()
	apply_central_force(movement*SPEED)
	apply_torque(rotation*ROTATION_SPEED)
