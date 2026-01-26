class_name NodeFSM extends Node

var object_fsm : FiniteStateMachine

func _ready() -> void:
	object_fsm.ready_fsm()

func _process(delta: float) -> void:
	object_fsm.delta = delta
	object_fsm.execute_process_methods()

func _physics_process(delta: float) -> void:
	object_fsm.delta = delta
	object_fsm.execute_current_state()
	object_fsm.execute_physiscs_process_methods()

func OnReadyFSM() -> void:
	pass
