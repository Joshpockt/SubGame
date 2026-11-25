@tool
extends Node3D

@export_tool_button("Reset") var all_step_action = all_step
@export var step_wait := 0.5

var a_b := false
@export var step_group_1 : Array[IKThing]
@export var step_group_2 : Array[IKThing]


var current_step_wait := 0.0
func all_step():
	for child in get_children():
		if child is IKThing:
			child.step()

func _process(delta: float) -> void:
	current_step_wait += delta
	position = $"..".velocity.rotated(Vector3.DOWN ,$"..".global_rotation.y).normalized() * 0.75
	
	
	if current_step_wait < step_wait: return
	current_step_wait = 0.0
	
	if a_b == true:
		for ik in step_group_1:
			a_b = false
			ik.step()
	else:
		for ik in step_group_2:
			a_b = true
			ik.step()
	
	#if !step_group_1[0].is_stepping:
		#for ik in step_group_1:
			#ik.step()
	#elif !step_group_2[0].is_stepping:
		#for ik in step_group_2:
			#ik.step()
