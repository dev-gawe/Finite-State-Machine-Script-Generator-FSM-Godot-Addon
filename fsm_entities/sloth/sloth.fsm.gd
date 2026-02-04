extends SlothStates
class_name SlothFSM 


## --- FSM METHODS ---


func execute_ready_methods() -> void:
	change_state(STATE_IDLE)

func execute_input_methods() -> void:
	UpdateInputs()

func execute_physiscs_process_methods() -> void:
	# e.g. move and slide
	pass

func execute_process_methods() -> void:
	pass


## --- SCENE NODES ---


var root : Node2D # / Node / CharacterBody2D / Node3D / CharacterBody3D / ...
var label : Label


## --- Shared Properties and Methods for All Entity States ---


var input_idle : bool
var input_rest : bool



func UpdateInputs() -> void :
	input_idle = Input.is_action_just_released("ui_accept")
	input_rest = Input.is_action_just_pressed("ui_accept")


func CanIdle() -> void:
	if input_idle:
		change_state(STATE_IDLE)


func CanRest() -> void:
	if input_rest:
		change_state(STATE_REST)



func Rest():
	label.text = "Resting"


func Idle():
	label.text = "Idling"


#

