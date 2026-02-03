extends State
class_name StateSlothIdle


var this: SlothFSM

func config_state():
	this = (controlled_node as SlothFSM)

func enter():
	print("Sloth Idle Entered")

func loop():
	this.Idle()

func exit():
	print("Sloth Idle Exited")

func change_state_when():
	this.CanRest()

# --- State Methods ---

pass
