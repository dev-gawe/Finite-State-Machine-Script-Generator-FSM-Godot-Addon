extends State
class_name StateSlothRest



var this: SlothFSM

func config_state():
	this = (controlled_node as SlothFSM)



func enter():
	on_entered.emit()
	print("Sloth Rest Entered")

func loop():
	this.Rest()

func exit():
	on_exited.emit()
	print("Sloth Rest Exited")



func change_state_when():
	this.CanIdle()


# --- State Methods ---


#

