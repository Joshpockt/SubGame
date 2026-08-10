extends Sprite2D

var delay := 0.0

func _ready() -> void:
	hide()
	await get_tree().create_timer(delay).timeout
	show()
	var tween := get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(modulate, 0), 1.75)
	await tween.finished
	queue_free()
