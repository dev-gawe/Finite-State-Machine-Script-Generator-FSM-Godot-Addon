extends CotorraStates
class_name CotorraFSM 


## --- FSM NODE LOOPS CALLBACKS ---


func execute_ready_methods() -> void:
	change_state(STATE_IDLE)

func execute_input_methods() -> void:
	UpdateInputs()

func execute_physiscs_process_methods() -> void:
	# e.g. move and slide
	pass

func execute_process_methods() -> void:
	pass


## --- Cotorra SCENE NODES ---


var root : Node2D # / Node / CharacterBody2D / Node3D / CharacterBody3D / ...
var label : Label


## --- Shared Properties and Methods for All Entity States ---

var input_duck : bool
var input_walk : float

func UpdateInputs() -> void :
	input_duck = Input.is_action_pressed("ui_accept")
	input_walk = Input.get_axis("ui_left","ui_right")

func Walk():
	label.text = "Walking"

func LeaveWalkState():
	if input_duck:
		change_state(STATE_DUCK)
	elif not input_walk:
		change_state(STATE_IDLE)

func LeaveIdleState() -> void:
	if input_duck:
		change_state(STATE_DUCK)
	elif input_walk:
		change_state(STATE_WALK)


func LeaveDuckState() -> void:
	if not input_duck:
		change_state(STATE_IDLE)



func Duck():
	label.text = "Ducking"


func Idle():
	label.text = "Idling"


#
