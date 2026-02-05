class_name FiniteStateMachine

var delta : float
var event : InputEvent

var current_state: State = null

""" FSM Methods """

func change_state(new_state: State) -> void:
	call_deferred("_cd_change_state",new_state)

func _cd_change_state(new_state:State) -> void:
	if current_state:
		current_state.exit()
	
	current_state = new_state
	
	if current_state:
		current_state.enter()

func execute_current_state() -> void: # Always running in _physic_process
	if current_state:
		current_state.loop()
		current_state.switch_state()

""" Node Loops Callbacks """


func execute_ready_methods() -> void:
	pass

func execute_input_methods() -> void:
	pass

func execute_shortcut_input_methods() -> void:
	pass

func execute_unhandled_input_methods() -> void:
	pass

func execute_unhandled_key_input_methods() -> void:
	pass

func execute_physiscs_process_methods() -> void:
	pass

func execute_process_methods() -> void:
	pass

func execute_draw_methods() -> void:
	pass
