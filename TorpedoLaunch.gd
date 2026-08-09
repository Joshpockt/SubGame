extends RigidBody3D

@onready var sync: MultiplayerSynchronizer = $Sync
# ALERT: tsk tsk tsk, i smell a weak ref...
	#var LockedOnto = null
# Should be-
var LockedOnto :Enemy= null
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

@onready var explode_ray: RayCast3D = $ExplodeRay
const EXPLOSION = preload("res://explosion.tscn")
var exploded=false


var canAbort=false # i forgot to push this stuff yesterday
var aborted=false


func _ready() -> void:
	if !multiplayer.is_server():
		freeze=true #Only server simulates torpedos, pos and rot are replicated, might add lerping for smoothness

func Thrust():
	if LockedOnto == null:return
	var current_direction = global_transform.basis.z
	var target_position = LockedOnto.LockOntoOffset
	var target_distance = global_position.distance_to(LockedOnto.LockOntoOffset)
	
	var time_of_flight = target_distance / linear_velocity.length()
	# this is a really weak way to refrence this, but we also dont have
	# any other creatures added so i dont care + shut up.
	var target_speed = LockedOnto.head.linear_velocity
	# really simple equation but should work
	var impact_position = LockedOnto.LockOntoOffset + target_speed * (time_of_flight * 1.0)
	
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

	Utils.ExplodeAt(global_position,get_parent(),5) #moved explosions into a function
	
	ParticleDebris.AddParticle($thrust2,5,get_parent()) #created a debris system for particles
	ParticleDebris.AddParticle($thrust,5,get_parent())
	
	await get_tree().process_frame
	queue_free()


func impactHandler():
	if explode_ray.is_colliding() && !exploded:
		exploded=true
		if explode_ray.get_collider() is SerpentSegment: #temporary
			explode_ray.get_collider().rpc("Gib")
		rpc("Detonate")

var guidance_cd := 0.0
func _physics_process(delta: float) -> void:
	if exploded == true: return
	if !multiplayer.is_server(): return
	
	guidance_cd += delta
	Thrust()
	impactHandler()

		
