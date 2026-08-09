extends RigidBody3D

const SPEED = 150.0
const ROTATION_SPEED=150.0
const VERTICAL_SPEED = 80
@onready var front_view_camera: Camera3D = $FrontView/Camera
@onready var front_view_anchor: Node3D = $FrontViewAnchor
@onready var bumper: Area3D = $Bumper
@onready var collider: CollisionShape3D = $Bumper/Collider
@onready var torpedo_cam: Camera3D = $TorpedoView/TorpedoCam
@onready var torpedo_view_anchor: Node3D = $TorpedoViewAnchor
@onready var torpedo_station: Node3D = $"../../../Ship/TorpedoStation"

var shakeCooldown=0.0
var lastMagnitude=0.0
var lastlastMagnitdue=0.0
var Damage=0
var isColliding=false
var currentCollisionPoint=Vector3.ZERO
var syncTimer=10
@onready var sound_radius: CollisionShape3D = $LoudnessRadius/radius

@onready var torpedo_launch: MeshInstance3D = $TorpedoLaunch
@onready var creatures: Node3D = $"../Creatures"

var base_torpedo = preload("res://base_torpedo.tscn")
var firedTorpedos=0
var torpedoLoaded=true:
	get():
		return true
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
	
@rpc("authority","call_local","reliable")
func reSync(pos,rot):
	global_position=pos
	global_rotation=rot

@rpc("any_peer","call_remote","reliable")
func RequestTorpedoFire(creatureId):
	if !torpedoLoaded: return
	firedTorpedos+=1
	rpc("fireTorpedo",firedTorpedos,creatureId)


@rpc("any_peer","call_local","reliable")
func fireTorpedo(id,cid):
	firedTorpedos=id
	torpedoLoaded=false
	var torpedo = base_torpedo.instantiate()
	get_parent().add_child(torpedo)
	torpedo.LockedOnto = creatures.creatures[cid]
	torpedo.name="Torpedo"+str(id)
	Utils.SnapTo(torpedo,torpedo_launch)


func _process(delta: float) -> void:
	torpedo_launch.visible=torpedoLoaded
	Utils.SnapTo(front_view_camera,front_view_anchor)
	Utils.SnapTo(torpedo_cam,torpedo_view_anchor)
	shakeCooldown-=delta
	if syncronizer.is_multiplayer_authority():
		if syncTimer > 0:
			syncTimer-=delta
		else:
			syncTimer=10
			rpc("reSync",global_position,global_rotation)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	isColliding=state.get_contact_count()!=0
	if isColliding:
		currentCollisionPoint=to_local(state.get_contact_collider_position(0))
		
	
	
func _physics_process(_delta: float) -> void:
	#print(linear_velocity.length()+angular_velocity.length()*10)
	sound_radius.shape.set("radius",(linear_velocity.length()+angular_velocity.length())*15)
	if isColliding && syncronizer.is_multiplayer_authority():
		if shakeCooldown <= 0 && lastlastMagnitdue > 1.8:
			rpc("SubCollides")
	lastlastMagnitdue=lastMagnitude
	lastMagnitude=(linear_velocity.length()+angular_velocity.length())
	if !syncronizer.is_multiplayer_authority() || !inUse || !hasPower:return
	var movement_dir := Input.get_vector("descend", "rise", "ui_up", "ui_down")
	var rotation_dir := Input.get_vector("ui_right", "ui_left", "ui_up", "ui_down")
	var movement := (transform.basis * Vector3(0, movement_dir.x, movement_dir.y)).normalized()
	var rot := (transform.basis * Vector3(0, rotation_dir.x, 0)).normalized()
	apply_central_force(movement*SPEED)
	apply_torque(rot*ROTATION_SPEED)
