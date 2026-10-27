extends MeshInstance3D

func _ready() -> void:
	ScreenManager.get_screen_deferred("SONAR", _got_texture)

func _got_texture(screen: ViewportTexture):
	material_override.set("shader_parameter/screen_texture", screen)
