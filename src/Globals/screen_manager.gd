extends Node

var screens : Dictionary[String, ViewportTexture]

func register_screen(viewport: SubViewport, id: String) -> void:
	if screens.has(id):
		push_error("Screen already registered with id: \"", id, "\"")
		return
	var texture : ViewportTexture = viewport.get_texture()
	screens[id] = texture
	#print(screens)

func get_screen(id) -> ViewportTexture:
	#print("id")
	if screens.has(id):
		return screens[id]
	else:
		push_error("Could not find screen with id: \"", id, "\"")
		return null
