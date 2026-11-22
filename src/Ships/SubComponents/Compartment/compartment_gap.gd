@tool
extends Marker3D
class_name CompartmentGap

## FIXME: Make this just "A" and "B." we dont need a whole array cause just
# working on 2 makes things alot easier
#@export var connected_compartments : Array[Compartment]
@export var compartment_a : Compartment
@export var compartment_b : Compartment
@export_custom(PROPERTY_HINT_NONE, "suffix:m^3/s") var max_flow_rate : float = 1.0
@export var is_open := true

func _update(delta):
	if is_open:
		balance(delta)

func balance(delta: float):
	if compartment_a.fill_level == 0.0 and compartment_b.fill_level == 0.0:
		return
	
	var source_compartment : Compartment = compartment_a
	var target_compartment : Compartment = compartment_b
	
	# Find higher and lower compartments
	if compartment_a.global_water_level > compartment_b.global_water_level:
		source_compartment = compartment_a
		target_compartment = compartment_b
	elif compartment_b.global_water_level > compartment_a.global_water_level:
		source_compartment = compartment_b
		target_compartment = compartment_a
	else:
		return # They are equal and dont need to be balanced
	
	if target_compartment.fill_level == 1.0:
		return
	
	var volume_delta : float = (max_flow_rate * 2) * delta
	var water_over = over(target_compartment.fill_volume + volume_delta, target_compartment.compartment_volume)
	if water_over > 0.0:
		source_compartment.remove_water((volume_delta * 0.5) - water_over)
		target_compartment.fill_level = 1.0
		return
	
	var level_difference := source_compartment.global_water_level - target_compartment.global_water_level
	# Im gonna kill whoever invented the ">" and "<" symbol.
	if level_difference < volume_delta * 0.5:
		#print("close")
		source_compartment.remove_water(level_difference * 0.5)
		target_compartment.add_water(level_difference * 0.5)
		return
	
	source_compartment.remove_water(volume_delta * 0.5)
	target_compartment.add_water(volume_delta * 0.5)


@warning_ignore("shadowed_global_identifier")
func over(x,max) -> float:
	return max(x, max) - max

#@warning_ignore("shadowed_global_identifier")
#func under(x, min) -> float:
	#return max(x, min) - min
