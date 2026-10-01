@abstract
extends Node3D
class_name State

# Call Order
#
# _idle_state_process
# ↓
# _check
# ↓
# _enter
# ↓
# _state_process
# ↓
# _exit

enum {
	SUCCESS,
	FAILURE,
	RUNNING,
}

@warning_ignore_start("unused_signal")
signal enter
signal exit

func _check() -> int:
	return FAILURE

func _enter():
	pass

func _exit():
	pass

## Only processes if "_check" returns SUCESS or RUNNING
@warning_ignore("unused_parameter")
func _state_process(delta: float) -> void:
	pass

## Gets processed regardless if the state is running or not
@warning_ignore("unused_parameter")
func _idle_state_process(delta: float) -> void:
	pass
