extends Area3D

@onready var interaction_area: InteractionArea = $InteractionArea


func _ready() -> void:
	var f = func(_id): remove.rpc()
	interaction_area.interacted.connect(f)

func _physics_process(delta: float) -> void:
	for area in get_overlapping_areas():
		if area is Compartment:
			#print(area)
			area.add_water(1.0 * delta)

@rpc("any_peer", "call_local", "reliable")
func remove():
	queue_free()
