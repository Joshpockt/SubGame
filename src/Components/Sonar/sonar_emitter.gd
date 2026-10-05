extends Area3D
class_name SonarEmitter

const EXPONENT := 2.0
enum SonarType {
	GENERIC,
	SUB,
	CREATURE,
	GEOLOGIC,
	SONAR,
}

var type : SonarType = SonarType.GENERIC
var volume := 0.0:
	set(value):
		volume = value
		collision_shape_3d.shape.radius = pow(volume, EXPONENT)

var volume_exp:
	get():
		return pow(volume, EXPONENT)

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
