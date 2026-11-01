extends Station
class_name TurretController

@export var mount : TurretMount
@export var turret_controller: SubWeaponController


var mouse_motion := Vector2.ZERO


func _process(_delta: float) -> void:
	super(_delta)
	#print(mount.azimuth_pivot.rotation.y)
	mouse_motion *= -0.00025
	mount.azimuth_pivot.rotation.y += mouse_motion.x
	mount.elevation_pivot.rotation.x += mouse_motion.y
	mouse_motion = Vector2.ZERO

func _control_process(_delta):
	if Input.is_action_just_pressed("shoot"):
		turret_controller.shoot()

func _control_input(event: InputEvent):
	if event is InputEventMouseMotion:
		#print("mouse_motion")
		mouse_motion += event.screen_relative
