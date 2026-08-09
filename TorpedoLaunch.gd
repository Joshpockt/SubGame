extends RigidBody3D

@onready var sync: MultiplayerSynchronizer = $Sync
# ALERT: tsk tsk tsk, i smell a weak ref...
	#var LockedOnto = null
# Should be-
var LockedOnto : Worm = null
# I also made the worm its own class.

#ok but like it won't ALWAYS be a worm that gets locked onto, thats why i didn't put it as a class

# Now we can directly access its properties
# without worrying if we spelled it correctly!


#yea i did name it like 3 different types of worms...
#but to be fair, i planned on changing all of this, 
#worm is a test until we get the serpant then its a full overhaul
#worm is more like an experiment to see ways i can do things when adding the serpant




var max_force = 80.0;
var max_torque = 0.25
#var damping = 8.0
@onready var explode_ray: RayCast3D = $ExplodeRay
const EXPLOSION = preload("res://explosion.tscn")
var exploded=false


var canAbort=false # i forgot to push this stuff yesterday
var aborted=false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !multiplayer.is_server():
		freeze=true
	$thrust.global_scale(Vector3.ONE)


@rpc("authority","call_local","reliable")
func reSyncRpc(pos, rot):
	global_position = pos
	global_rotation = rot

func Thrust():
	if LockedOnto == null:return
	var current_direction = global_transform.basis.z
	var target_position = LockedOnto.lockOnPos
	var target_distance = global_position.distance_to(LockedOnto.lockOnPos)
	
	var time_of_flight = target_distance / linear_velocity.length()
	# this is a really weak way to refrence this, but we also dont have
	# any other creatures added so i dont care + shut up.
	var target_speed = LockedOnto.head.linear_velocity
	# really simple equation but should work
	var impact_position = LockedOnto.lockOnPos + target_speed * (time_of_flight * 1.0)
	
	apply_central_force(current_direction * max_force)
	if aborted:return
	if guidance_cd <= 1.0:
		return
	
	var desired_direction = global_position.direction_to(impact_position)
	
	var axis = current_direction.cross(desired_direction)
	var difference=(current_direction-desired_direction).length()
	if canAbort && difference > .3:
		print("torpedo aborted")
		aborted=true
	if !canAbort && difference < .2:
		canAbort=true
	var angle = acos(clamp(current_direction.dot(desired_direction), -1.0, 1.0))
	apply_torque(axis.normalized() * angle * max_torque * pow(linear_velocity.length(), 2))

@rpc("authority","call_local","reliable")
func Detonate():
	print("caboom")
	exploded=true
	var explosion = EXPLOSION.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position=global_position
	explosion.get_child(0).emitting=true
	collision_layer = 0
	collision_mask = 0
	$Render.hide()
	$thrust2.emitting = false
	$thrust.emitting = false
	await get_tree().create_timer(5).timeout
	queue_free()


func impactHandler():
	if explode_ray.is_colliding() && !exploded:
		#print("kaboomalso")
		exploded=true
		if explode_ray.get_collider() is WormSegment:
			explode_ray.get_collider().rpc("Gib")
		rpc("Detonate")

var guidance_cd := 0.0
func _physics_process(delta: float) -> void:
	if exploded == true: return
#	print(linear_velocity.length())
	if !multiplayer.is_server(): return
	guidance_cd += delta
	Thrust()
	impactHandler()
	
	#reSync-=delta
	#if reSync < 0:
		#reSync=4.0
		#rpc("reSyncRpc",global_position,global_rotation)
		
