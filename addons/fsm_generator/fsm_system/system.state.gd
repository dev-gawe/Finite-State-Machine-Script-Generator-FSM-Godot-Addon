class_name State

var controlled_node : FiniteStateMachine

signal on_entered
signal on_exited

func _init(_obj_class : FiniteStateMachine) -> void:
	controlled_node = _obj_class
	config_state()

""" State Callbacks """

func config_state() -> void:
	pass

func enter() -> void:
	pass

func loop() -> void:
	pass

func exit() -> void:
	pass

func change_state_when() -> void:
	pass
