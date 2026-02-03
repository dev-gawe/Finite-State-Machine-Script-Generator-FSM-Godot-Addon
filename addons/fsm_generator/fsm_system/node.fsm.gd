class_name NodeFSM extends Node

var object_fsm : FiniteStateMachine

func _ready() -> void:
	object_fsm.execute_ready_methods()

func _process(delta: float) -> void:
	object_fsm.delta = delta
	object_fsm.execute_process_methods()

func _physics_process(delta: float) -> void:
	object_fsm.delta = delta
	object_fsm.execute_current_state()
	object_fsm.execute_physiscs_process_methods()

func _input(event: InputEvent) -> void:
	object_fsm.event = event
	object_fsm.execute_input_methods()

func _shortcut_input(event: InputEvent) -> void:
	object_fsm.event = event
	object_fsm.execute_shortcut_input_methods()

func _unhandled_input(event: InputEvent) -> void:
	object_fsm.event = event
	object_fsm.execute_unhandled_input_methods()

func _unhandled_key_input(event: InputEvent) -> void:
	object_fsm.event = event
	object_fsm.execute_unhandled_key_input_methods()
