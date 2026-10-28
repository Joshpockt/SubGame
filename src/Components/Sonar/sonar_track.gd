extends RefCounted
class_name SonarTrack

enum SonarType {
	GENERIC,
	SUB_GENERIC,
	SUB_SONAR,
	TORPEDO,
	CREATURE,
	GEOLOGIC,
}

var position : Vector3 = Vector3.ZERO
var type : SonarType = SonarType.GENERIC
var strength : float = 0.0
