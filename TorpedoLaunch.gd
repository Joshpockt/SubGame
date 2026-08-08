extends RigidBody3D

@onready var sync: MultiplayerSynchronizer = $Sync
var reSync=4.0
var LockedOnto = Vector3.ZERO
var speed=20.0;
var torque_strength = 40.0
var damping = 8.0
@onready var explode_ray: RayCast3D = $ExplodeRay
const EXPLOSION = preload("res://explosion.tscn")
var exploded=false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@rpc("authority","call_local","reliable")
func reSyncRpc(pos,rot):
	global_position=pos
	global_rotation=rot

func Thrust():
	var dir = global_transform.basis.z
	apply_central_force(dir*speed)
	var desired = (LockedOnto.lockOnPos - global_position).normalized()
	var current = global_transform.basis.z

	var axis = current.cross(desired)
	var angle = acos(clamp(current.dot(desired), -1.0, 1.0))

	apply_torque(axis.normalized() * angle * torque_strength- angular_velocity * damping)

@rpc("authority","call_local","reliable")
func Detonate():
	print("caboom")
	exploded=true
	var explosion = EXPLOSION.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position=global_position
	explosion.get_child(0).emitting=true
	queue_free()


func impactHandler():
	if explode_ray.is_colliding() && !exploded:
		print("kaboomalso")
		exploded=true
		rpc("Detonate")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !sync.is_multiplayer_authority(): return
	Thrust()
	impactHandler()
	
	reSync-=delta
	if reSync < 0:
		reSync=4.0
		rpc("reSyncRpc",global_position,global_rotation)
		
