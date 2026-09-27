extends Area3D
class_name InteractionArea

signal interacted(peer_id: int)
signal observed

func inteact(peer_id: int) -> void:
	interacted.emit(peer_id)

func observe() -> void:
	observed.emit()


# For classes that use this node
#func _ready() -> void:
	#interaction_area.interacted.connect(_interacted)
#
#func _interacted(peer_id: int) -> void:
	#pass
