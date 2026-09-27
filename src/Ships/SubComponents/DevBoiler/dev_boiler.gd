extends Node3D

@onready var interaction_area: InteractionArea = $InteractionArea

func _ready() -> void:
	interaction_area.interacted.connect(_interacted)

func _interacted(peer_id: int) -> void:
	print("fuel")
	SubInterior.interior_instance.fuel += 30

func _process(delta: float) -> void:
	$Node3D.rotation.z = - (SubInterior.interior_instance.fuel_uniform * 2 - 1) * PI * 0.8
