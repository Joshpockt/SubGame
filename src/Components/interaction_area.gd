extends Area3D
class_name InteractionArea

signal interacted(peer_id: int)
signal observed

func inteact(peer_id: int) -> void:
	interacted.emit(peer_id)

func observe() -> void:
	observed.emit()
