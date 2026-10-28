extends Sprite2D
class_name Blip

var color : Color = Color.WHITE
var duration := 3.0

func _ready() -> void:
	modulate = color - Color(0,0,0,1)
	var tween := get_tree().create_tween()
	
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "modulate", color, 0.15)
	tween.tween_property(self, "modulate", Color(Color.BLACK), duration)
	#await get_tree().create_timer(2.0).timeout
	await tween.finished
	queue_free()
