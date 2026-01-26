class_name StateSlothRest extends State


var this: SlothFSM

func config_state():
	this = (controlled_node as SlothFSM)

func enter():
	this.Stop()

func loop():
	this.Idle()

func exit():
	pass

func change_state_when():
	this.CanRest()

# --- State Methods ---

pass


