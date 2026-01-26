class_name SlothFSM extends FiniteStateMachine


func ready_fsm() -> void:
	change_state(STATE_IDLE)


func execute_process_methods() -> void:
	UpdateInputs()


func execute_physiscs_process_methods():
	pass
	# Example: Here, you can character.move_and_slide() after current_state_machine loop runs
	#     or any command (methods/setters)


#var character : CharacterBody2D
var sprites : AnimatedSprite2D
var audio2d : AudioStreamPlayer2D


## --- ADD STATES ---


var STATE_IDLE : StateSlothIdle = StateSlothIdle.new(self)
var STATE_REST : StateSlothRest = StateSlothRest.new(self)


## --- Properties and Methods For All Object States ---

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


