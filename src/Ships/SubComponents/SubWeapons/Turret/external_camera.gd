extends RemoteTransform3D

@export var screen_id := ""

@onready var sub_viewport: SubViewport = $"../SubViewport"


func _ready() -> void:
	ScreenManager.register_screen(sub_viewport, screen_id)
