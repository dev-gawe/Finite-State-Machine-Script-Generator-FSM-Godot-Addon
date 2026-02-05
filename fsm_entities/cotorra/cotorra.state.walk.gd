extends State
class_name StateCotorraWalk



var this: CotorraFSM

func setup_state():
	this = (controlled_node as CotorraFSM)


func enter():
	pass

func loop():
	this.Walk()

func exit():
	pass


func switch_state():
	this.LeaveWalkState()


# --- State Methods ---


#
