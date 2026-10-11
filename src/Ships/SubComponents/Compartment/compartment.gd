@tool
extends Area3D
class_name Compartment

@export var compartment_volume : float:
	get():
		if not $CollisionShape3D: return 0.0
		$CollisionShape3D.debug_color.a = 1.0
		if $CollisionShape3D.shape is BoxShape3D:
			var x = $CollisionShape3D.shape.size.x
			var y = $CollisionShape3D.shape.size.y
			var z = $CollisionShape3D.shape.size.z
			return x * y * z
		return 0.0


func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var result := []
	if !$CollisionShape3D.shape is BoxShape3D:
		result.append("Compartments shape is not a BoxShape3D.")
	return result
