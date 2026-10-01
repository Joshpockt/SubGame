extends Node3D
class_name StateMachine

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

@export var starting_state : State

var states : Array[State]
var current_state : State
var current_interupt : State

enum {
	SUCCESS,
	FAILURE,
	RUNNING,
}

func _ready() -> void:
	for child in get_children():
		var checked_state = check_state_eligibility(child)
		if checked_state != null:
			add_state(checked_state)
	
	assert(not states.is_empty())
	if starting_state: current_state = starting_state
	else: current_state = states[0]

## Lets you decide if a node should be added as a state.
## Useful if you want a specfic type of state in a certan state machine.
func check_state_eligibility(state: State) -> State:
	if state is State:
		return state
	else:
		return null

func add_state(state: State) -> void:
	states.append(state)

func remove_state(state: State) -> void:
	if states.has(state):
		states.erase(state)

#WARNING: Will overwrite any current interupt!
func interupt(state: State) -> void:
	if check_state_eligibility(state) is State:
		current_interupt = state
		#print(current_interupt is State)
	else:
		push_error("State is not eligible for this State Machine: ", state)

func has_queued_interupt() -> bool:
	return current_interupt != null

var state_found := false
func process_states(delta: float) -> void:
	assert(current_state != null, str(name) + ": Current state is missing!")
	state_found = false
	
	# give all states their idle tick
	for state in states:
		state._idle_state_process(delta)
	
	if current_interupt is State:
		#print(current_interupt)
		_tick_state(current_interupt, delta)
		current_interupt = null
		return
	
	if current_state._check() == RUNNING:
		_tick_state(current_state, delta)
		return
	
	for state in states:
		var check = state._check()
		if check == SUCCESS or check == RUNNING:
			_tick_state(state, delta)
			return
	
	## if current interupt exists then run it.
	#if current_interupt is State:
		#for state in states:
			#state._idle_state_process(delta)
		#current_state._exit()
		#current_state = current_interupt
		#current_state._state_process(delta)
		#current_interupt = null
		#return
	#
	## If the current state is running then call _state_process() on it.
	#if current_state._check() == RUNNING:
		#for state in states:
			#state._idle_state_process(delta)
		#current_state._state_process(delta)
		#return
	#
	#for state in states:
		#state._idle_state_process(delta)
		#if (state._check() == SUCCESS or state._check() == RUNNING) and !state_found:
			## If the current state has changed call the appropriate functions
			#if state != current_state:
				#current_state._exit()
				#current_state = state
				#current_state._enter()
			#
			## Call the appropriate functions on the state
			#state._state_process(delta)
			#current_state = state
			#state_found = true
	#
	##if backup_state:
	##	backup_state._state_process(delta)


func _tick_state(state: State, delta: float) -> void:
	if current_state != state:
		current_state._exit()
		current_state.exit.emit()
		current_state = state
		current_state._enter()
		current_state.enter.emit()
	
	current_state._state_process(delta)
