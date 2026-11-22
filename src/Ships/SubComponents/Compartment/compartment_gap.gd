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

#@export_tool_button("Balance") var balance_action = func(): balance(1/60)

#var penis := 0
func _update(delta):
	#penis += 1
	#print(penis)
	#if penis >= 120:
		#print("penis")
		#is_open = true
	#
	if is_open:
		balance(delta)

func balance(delta: float):
	var higher_compartment : Compartment = compartment_a
	var lower_compartment : Compartment = compartment_b
	
	# Find higher and lower compartments
	if compartment_a.global_water_level > compartment_b.global_water_level:
		higher_compartment = compartment_a
		lower_compartment = compartment_b
	elif compartment_b.global_water_level > compartment_a.global_water_level:
		higher_compartment = compartment_b
		lower_compartment = compartment_a
	else:
		return # They are equal and dont need to be balanced
	
	if lower_compartment.fill_level == 1.0:
		return
	
	var volume_delta : float = (max_flow_rate * 2) * delta
	#volume_delta = min(volume_delta, higher_compartment.fill_volume/2)
	var water_over = over(lower_compartment.fill_volume + volume_delta, lower_compartment.compartment_volume)
	if water_over > 0.0:
		higher_compartment.remove_water(volume_delta - water_over)
		#print(volume_delta - water_over)
		lower_compartment.fill_level = 1.0
		return
	
	#print(volume_delta)
	
	higher_compartment.remove_water(volume_delta/2)
	lower_compartment.add_water(volume_delta/2)


@warning_ignore("shadowed_global_identifier")
func over(x,max) -> float:
	return max(x, max) - max


# Here lies dead code that sucked ass.
# You shall not be missed...

	#var total_water : float = 0.0
	#var smallest_volume : float = INF
	#for compart in connected_compartments:
		#total_water += compart.fill_volume
		#if compart.compartment_volume < smallest_volume:
			#smallest_volume = compart.compartment_volume
	#
	#if total_water == 0.0:
		#return
	#
	#var filled_volume : float = 0.0
	#var left_over_volume : float = 0.0
	#var filled_compartments : int = 0
	##print(compart.compartment_volume / total_water)
	##print(compart.compartment_volume / connected_compartments.size())
	##print(total_water)
	#for ment in connected_compartments:
		##if ment == compart: continue
		##print(ment.compartment_volume / total_water)
		#if ment.compartment_volume / connected_compartments.size() >= 1 / total_water:
			#print("pingus")
			#filled_volume += ment.compartment_volume
			#left_over_volume += max(ment.fill_volume, ment.compartment_volume) - ment.compartment_volume
			#filled_compartments += 1
	#
	#
	##print(filled_volume)
	##print(left_over_volume)
	##print(filled_compartments)
	#for compart in connected_compartments:
		#compart.fill_volume = ((total_water - filled_volume) + left_over_volume) / (connected_compartments.size())
		##compart.fill_volume = total_water / connected_compartments.size()
