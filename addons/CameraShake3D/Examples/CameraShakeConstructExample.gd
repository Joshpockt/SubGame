extends Node
class_name CameraShakeConstructExample

@export var camera : Camera3D

var cameraShake : CameraShake3D

# init
func _ready() -> void:
	cameraShake = CameraShake3D.new(camera)

func _process(delta: float) -> void:
	# must manually update the camera shake
	cameraShake._update(delta)

	
	pass
