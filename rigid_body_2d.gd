extends RigidBody2D


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#print(state.get_contact_count())
	if state.get_contact_count() > 0:
		print(state.get_contact_impulse(0))
