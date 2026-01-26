class_name FiniteStateMachine

var delta : float

var current_state: State = null

func ready_fsm() -> void:
	pass

func change_state(new_state: State) -> void:
	call_deferred("_cd_change_state",new_state)

func _cd_change_state(new_state:State) -> void:
	if current_state:
		current_state.exit()
	
	current_state = new_state
	
	if current_state:
		current_state.enter()

func execute_current_state() -> void:
	if current_state:
		current_state.loop()
		current_state.change_state_when()

func execute_process_methods() -> void:
	pass

func execute_physiscs_process_methods():
	pass
