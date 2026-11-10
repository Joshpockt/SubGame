extends CanvasLayer

@onready var fps_label: Label = %FPSLabel
@onready var frame_time_label: Label = %FrameTimeLabel
@onready var frames_label: Label = %FramesLabel
@onready var ticks_label: Label = %TicksLabel

func _ready() -> void:
	hide()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_menu"):
		if !visible:
			show()
		else:
			hide()
	
	if visible:
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
		frame_time_label.text = "Frame Time ms: " + str(Performance.get_monitor(Performance.TIME_PROCESS) * 1000)
		frames_label.text = "Frames Drawn: " + str(Engine.get_frames_drawn())
		ticks_label.text = "Game Ticks: " + str(Engine.get_physics_frames())
