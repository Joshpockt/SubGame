@tool
extends CharacterBody3D

@export_tool_button("go") var go_action = go
@export_tool_button("stop") var stop_action = stop

@onready var front_l_target: Marker3D = $Front_L_Target
@onready var front_r_target: Marker3D = $Front_R_Target
@onready var mid_l_target: Marker3D = $Mid_L_Target
@onready var mid_r_target: Marker3D = $Mid_R_Target
@onready var back_l_target: Marker3D = $Back_L_Target
@onready var back_r_target: Marker3D = $Back_R_Target

@onready var front_l_marker: Marker3D = $Front_L_Marker
@onready var front_r_marker: Marker3D = $Front_R_Marker
@onready var mid_l_marker: Marker3D = $Mid_L_Marker
@onready var mid_r_marker: Marker3D = $Mid_R_Marker
@onready var back_l_marker: Marker3D = $Back_L_Marker
@onready var back_r_marker: Marker3D = $Back_R_Marker

@onready var target_container: Node3D = $Targets
@onready var marker_container: Node3D = $Markers

func go():
	velocity.z = -0.5

func stop():
	velocity = Vector3.ZERO

func _physics_process(delta: float) -> void:
	move_and_slide()

#func reset():
	#var targets : Array = target_container.get_children()
	#
	#var markers : Array = marker_container.get_children()
	#
	#for i in targets.size():
		#targets[i].global_position = markers[i].global_position

#func _physics_process(delta: float) -> void:
	#var targets : Array = target_container.get_children()
	#
	#var markers : Array = marker_container.get_children()
	#
	#for i in targets.size():
		#if targets[i].global_position.distance_to(markers[i].global_position) > 1.1:
			#targets[i].global_position = markers[i].global_position
