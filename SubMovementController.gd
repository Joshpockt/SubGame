extends RigidBody3D

const SPEED = 300.0
const ROTATION_SPEED=150.0
#const SPEED = 1000.0
#const ROTATION_SPEED=2000.0
const VERTICAL_SPEED = 80
@onready var front_view_camera: Camera3D = $FrontView/Camera
@onready var front_view_anchor: Node3D = $FrontViewAnchor
@onready var bumper: Area3D = $Bumper
@onready var collider: CollisionShape3D = $Bumper/Collider
@onready var torpedo_cam: Camera3D = $TorpedoView/TorpedoCam
@onready var torpedo_view_anchor: Node3D = $TorpedoViewAnchor
@onready var torpedo_station: Node3D = $"../../../Ship/TorpedoStation"
@onready var snow: GPUParticles3D = $Snow
@onready var active_sonar_view: SubViewport = $ActiveSonarView
@onready var ring: Sprite2D = $ActiveSonarView/Ring
@onready var sonar_camera: Camera2D = $ActiveSonarView/SonarCenter/SonarCamera
# FIXME: change name
@onready var sonar_center: Sprite2D = $ActiveSonarView/SonarCenter
const SONAR_BLIP = preload("uid://dbg3jp5gjmcgb")
# i know this is yucky i dont care
@onready var sonar_ray: RayCast3D = $SonarOrigin/Sonar

var sonar_range = 300.0
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
	var torpedo : Node3D = base_torpedo.instantiate()
	get_parent().add_child(torpedo)
	torpedo.LockedOnto = creatures.creatures[cid]
	torpedo.name="Torpedo"+str(id)
	torpedo.global_position = torpedo_launch.global_position
	torpedo.global_rotation = torpedo_launch.global_rotation


func _process(delta: float) -> void:
	sonar_pulse(delta)
	
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


var sonar_clock := 0.0
func sonar_pulse(delta) -> void:
	# Im gonna try my best to explain what is happening here
	# i know this code is incredibly brittle, but i dont care >:P
	sonar_clock += delta
	if sonar_clock >= 1.75:
		# number of rays is a power of 2
		var sonar_precision = pow(2,6)
		@warning_ignore("integer_division")
		for i in sonar_precision:
			var angle : float = i / (sonar_precision / TAU)
			# We add a random number to make the rays feel less "stiff"
			var direction := Vector3(sin(angle + randf() * 0.1), 0, cos(angle + randf() * 0.1))
			#var direction := Vector3(sin(angle), 0.0, cos(angle))
			sonar_ray.target_position = direction * sonar_range
			sonar_ray.force_raycast_update()
			var hit_position := Vector3.ZERO
			var distance := 0.0
			# If the ray hit something, we log that. else we just move to the next ray
			if sonar_ray.is_colliding():
				hit_position = sonar_ray.get_collision_point()
				distance = to_local(sonar_ray.get_collision_point()).length()
			else:
				continue
			# Make a new blip
			var blip_instance : Node2D = SONAR_BLIP.instantiate()
			# Set its delay, this will make it appear later
			# (yes yes i know i came on your ass about weak refrences but shhhhhhh)
			blip_instance.delay = distance / 300
			# Then we just set the position in global space
			#blip_instance.position = Vector2(hit_position.x, hit_position.z)
			active_sonar_view.add_child(blip_instance)
			# Then we just set the position in global space
			blip_instance.position = Vector2(hit_position.x, hit_position.z)
		
		# Ring just always expands, we just set it to zero when we send out a pulse
		ring.scale = Vector2.ZERO
		ring.position = Vector2(position.x, position.z)
		sonar_clock = 0.0
	# then we update the dummy sub on the sonar
	sonar_center.position = Vector2(position.x, position.z)
	sonar_center.rotation = -rotation.y
	ring.scale += Vector2.ONE * delta * 1.40

var sonar_angle := 0.0
func sonar_spin(delta) -> void:
	sonar_angle += delta * 5
	var direction := Vector3(sin(sonar_angle), 0, cos(sonar_angle))
	sonar_ray.target_position = direction * sonar_range
	force_update_transform()
	
	var hit_position = sonar_ray.get_collision_point()
	#var distance = global_position.distance_to(hit_position)
	var blip_instance : Node2D = SONAR_BLIP.instantiate()
	
	#blip_instance.delay = distance / 300
	#blip_instance.position = Vector2(hit_position.x, hit_position.z)
	active_sonar_view.add_child(blip_instance)
	blip_instance.position = Vector2(hit_position.x, hit_position.z)
	
	sonar_center.position = Vector2(position.x, position.z)
	sonar_center.rotation = -rotation.y

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	isColliding=state.get_contact_count()!=0
	if isColliding:
		currentCollisionPoint=to_local(state.get_contact_collider_position(0))
		
	
	
func _physics_process(_delta: float) -> void:
	#print(linear_velocity.length()+angular_velocity.length()*10)
	sound_radius.shape.set("radius",clamp((linear_velocity.length()+angular_velocity.length())*15,.1,9000))
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
	var rotation_speed_mult = max(1, abs(linear_velocity.dot(-global_basis.z)) * linear_velocity.length() * 0.05)
	apply_central_force(movement*SPEED)
	apply_torque(rot*ROTATION_SPEED * rotation_speed_mult)
