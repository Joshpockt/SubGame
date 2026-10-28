extends Node3D

@onready var sonar_emitter: SonarEmitter = $SonarEmitter

func _ready() -> void:
	sonar_emitter.type = SonarTrack.SonarType.GEOLOGIC
	sonar_emitter.volume = 30
