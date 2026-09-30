extends Area3D
class_name InteractionArea

## A generalized class for handling player interactions

signal interacted(peer_id: int)
signal intreaction_started(peer_id: int)
signal interaction_stopped(peer_id: int)
#signal interaction_finished(peer_id: int)
signal observed(peer_id: int)

@export_range(0.0, 10.0, 0.1, "or_greater") var interaction_time := 0.0
@export var disable_interaction := false
@export var disable_observation := false
@export var allow_swipe := false

var current_interaction_time := 0.0
var is_being_interacted := false
var interaction_progress : float:
	get():
		if interaction_time == 0.0:
			return 1.0
		return current_interaction_time / interaction_time


func inteact(peer_id: int) -> void:
	if disable_interaction: return
	#print("interact")
	interacted.emit(peer_id)

func start_interaction(peer_id: int) -> void:
	if disable_interaction: return
	#print("start_interact")
	intreaction_started.emit(peer_id)
	is_being_interacted = true

func stop_interaction(peer_id: int) -> void:
	if disable_interaction: return
	#print("stop_interact")
	interaction_stopped.emit(peer_id)
	is_being_interacted = false

#func finish_interaction(peer_id: int) -> void:
	#print("finish_interaction")
	#interaction_finished.emit(peer_id)

func observe(peer_id: int) -> void:
	if disable_observation: return
	#print("observe")
	observed.emit(peer_id)


# For classes that use this node
#func _ready() -> void:
	#interaction_area.interacted.connect(_interacted)
#
#func _interacted(peer_id: int) -> void:
	#pass
