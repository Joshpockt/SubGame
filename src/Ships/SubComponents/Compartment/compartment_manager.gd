@tool
extends Node3D
class_name CompartmentManager

@export_tool_button("Update Compartments") var pp_penis = func(): update_compartment_setup()
@export_group("Data")
@export var compartments : Array[Compartment]
@export var compartment_gaps : Array[CompartmentGap]

func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		update_compartment_setup()

func update_compartment_setup():
	print("Updating compartments...")
	compartments.clear()
	compartment_gaps.clear()
	
	for child in get_children():
		if child is Compartment:
			compartments.append(child)
		
		if child is CompartmentGap:
			compartment_gaps.append(child)
	print("Done updating compartments.")

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	for compartment in compartments:
		compartment._update(delta)
	for gap in compartment_gaps:
		#compartment_gaps.shuffle()
		gap._update(delta)
