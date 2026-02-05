class_name State

signal on_entered
signal on_exited

var controlled_node : FiniteStateMachine

func _init(_obj_class : FiniteStateMachine) -> void:
	controlled_node = _obj_class
	setup_state()

""" State Callbacks """

func setup_state() -> void:
	pass

func enter() -> void:
	pass

func loop() -> void:
	pass

func exit() -> void:
	pass

func switch_state() -> void:
	pass
