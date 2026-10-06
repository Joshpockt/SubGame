extends Sprite3D

func _ready() -> void:
	ScreenManager.get_screen_deferred("FRONT", _got_texture)

func _got_texture(screen: ViewportTexture):
	texture = screen
