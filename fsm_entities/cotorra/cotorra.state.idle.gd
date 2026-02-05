extends State
class_name StateCotorraIdle



var this: CotorraFSM

func setup_state():
	this = (controlled_node as CotorraFSM)



func enter():
	print("Cotorra Idle Entered")

func loop():
	this.Idle()

func exit():
	print("Cotorra Idle Exited")



func switch_state():
	this.LeaveIdleState()


# --- State Methods ---


#

