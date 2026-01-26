extends NodeFSM
class_name NodeSloth

## TODO attach this node on your own Sloth.tscn

var sloth_fsm : SlothFSM

func _init() -> void:
	object_fsm = SlothFSM.new()
	sloth_fsm = object_fsm

## TODO New Nodes

@export var root : Node : ## Node2D / Node3D, CharacterBody2D, CharacterBody3D, etc.
	set(value):
		sloth_fsm.root = value


@export var label : Label :
	set(value):
		sloth_fsm.label = value
