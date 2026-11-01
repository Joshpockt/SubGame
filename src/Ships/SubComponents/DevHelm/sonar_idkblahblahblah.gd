extends MeshInstance3D

@export var screen_id = ""

func _ready() -> void:
	ScreenManager.get_screen_deferred(screen_id, _got_texture)

func _got_texture(screen: ViewportTexture):
	material_override.set("shader_parameter/screen_texture", screen)
