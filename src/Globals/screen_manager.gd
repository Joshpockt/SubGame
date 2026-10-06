extends Node

var screens : Dictionary[String, ViewportTexture]
var requests : Dictionary[String, Array]

func register_screen(viewport: SubViewport, id: String) -> void:
	if screens.has(id):
		push_error("Screen already registered with id: \"", id, "\"")
		return
	var texture : ViewportTexture = viewport.get_texture()
	screens[id] = texture
	if requests.has(id):
		for request : Callable in requests[id]:
			request.call(texture)
	#print(screens)

func get_screen(id: String) -> ViewportTexture:
	#print("id")
	if screens.has(id):
		return screens[id]
	else:
		#push_error("Could not find screen with id: \"", id, "\"")
		return null

func get_screen_deferred(id: String, callback: Callable) -> void:
	if screens.has(id):
		callback.call(screens[id])
	else:
		if requests.has(id):
			requests[id].append(callback)
		else:
			requests[id] = [callback]
