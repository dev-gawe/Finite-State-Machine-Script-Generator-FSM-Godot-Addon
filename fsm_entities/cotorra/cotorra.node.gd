extends NodeFSM
class_name NodeCotorra


## --- FSM Setup ---


var cotorra_fsm : CotorraFSM


func _init() -> void:
	object_fsm = CotorraFSM.new()
	cotorra_fsm = object_fsm


## --- Scene Nodes ---


@export var root : Node2D : # / Node / CharacterBody2D / Node3D / CharacterBody3D / ...
	set(value):
		cotorra_fsm.root = value


@export var label : Label :
	set(value):
		cotorra_fsm.label = value


#

