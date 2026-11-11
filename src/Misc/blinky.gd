extends Node3D

@export var offset := 0.0

@onready var omni_light_3d: OmniLight3D = $OmniLight3D
@onready var timer: Timer = $Timer

func _ready() -> void:
	omni_light_3d.hide()
	timer.timeout.connect(blink)
	var old_wait_time = timer.wait_time
	timer.wait_time -= offset
	await timer.timeout
	timer.wait_time = old_wait_time

func blink():
	omni_light_3d.show()
	await get_tree().create_timer(0.25).timeout
	omni_light_3d.hide()
