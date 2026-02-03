extends NodeFSM
class_name NodeSloth


## --- FSM Setup ---


var sloth_fsm : SlothFSM


func _init() -> void:
	object_fsm = SlothFSM.new()
	sloth_fsm = object_fsm


## --- Scene Nodes ---


@export var root : Node : # / Node2D / CharacterBody2D / Node3D / CharacterBody3D / ...
	set(value):
		sloth_fsm.root = value


@export var label : Label :
	set(value):
		sloth_fsm.label = value

