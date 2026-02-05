extends State
class_name StateCotorraDuck



var this: CotorraFSM

func setup_state():
	this = (controlled_node as CotorraFSM)



func enter():
	on_entered.emit()
	print("Cotorra Duck Entered")

func loop():
	this.Duck()

func exit():
	on_exited.emit()
	print("Cotorra Duck Exited")



func switch_state():
	this.LeaveDuckState()


# --- State Methods ---


#

