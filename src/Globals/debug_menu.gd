extends CanvasLayer

@onready var fps_label: Label = %FPSLabel
@onready var frames_label: Label = %FramesLabel

func _ready() -> void:
	hide()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_menu"):
		if !visible:
			show()
		else:
			hide()
	
	if visible:
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
		frames_label.text = "Frames Drawn: " + str(Engine.get_frames_drawn())
