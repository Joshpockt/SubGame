extends Sprite2D

func _ready() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(Color.TRANSPARENT), 2.5)
	#await get_tree().create_timer(2.0).timeout
	await tween.finished
	queue_free()
