@tool
extends AcceptDialog

@export var entity_input: LineEdit
@export var state_name_input: LineEdit
@export_dir var root_dir: String = "res://fsm_entities"

var place_holder : Array[String] = [
	"Run",
	"Fly",
	"Swim",
	"Push",
	"Sing",
	"Sleep",
	"Patrol"
]

func _ready() -> void:
	register_text_enter(entity_input)
	register_text_enter(state_name_input)
	hide_and_change_place_holder()
	
	confirmed.connect(_on_confirmed)
	canceled.connect(hide_and_change_place_holder)
	close_requested.connect(hide_and_change_place_holder)


func hide_and_change_place_holder():
	hide()
	entity_input.placeholder_text = place_holder.pick_random()


func _on_confirmed() -> void:
	print("Create Entity State: Initialized")
	
	## TODO: Si el NEW STATE está creado, avisar y cortar
	
	_process_state_generation()
	
	EditorInterface.get_resource_filesystem().scan()
	print("Create Entity State: Finished")

func _process_state_generation() -> void:
	
	var entity: String = entity_input.text.strip_edges().to_snake_case()
	var state: String = state_name_input.text.strip_edges().to_snake_case()
	
	
	if entity.is_empty() or state.is_empty():
		printerr("Generator: Please fill in both fields.")
		return
	
	
	var folder_path: String = root_dir.path_join(entity)
	var states_script_path: String = folder_path.path_join(
			"{entity}.states.gd"
			.format({"entity": entity})
		)
	var new_state_path: String = folder_path.path_join(
			"{entity}.state.{state}.gd"
			.format({"entity": entity, "state": state})
		)
	
	
	if FileAccess.file_exists(new_state_path):
		printerr("Generator: State file already exists at {path}. Aborting.".format({"path": new_state_path}))
		return
	
	
	_create_state_file(new_state_path, entity, state)
	
	
	_inject_state_into_fsm(states_script_path, entity, state)
	


func _create_state_file(path: String, entity_name: String, state_name: String) -> void:
	var entity_class: String = "State{entity}{state}".format({
		"entity": entity_name.to_pascal_case(),
		"state": state_name.to_pascal_case()
	})
	
	var template: String = _template_new_state()
	
	var content: String = template.format({
		"name_class": entity_class,
		"fsm_class": entity_name.to_pascal_case() + "FSM"
	})
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()


func _inject_state_into_fsm(states_path: String, entity_name : String, state_name: String) -> void:
	if not FileAccess.file_exists(states_path):
		printerr("Generator: FSM script not found at {path}".format({"path": states_path}))
		return
	
	var entity_class_name: String = "State{entity}{state}".format({
		"entity": entity_name.to_pascal_case(),
		"state": state_name.to_pascal_case()
	})
	
	var variable_name: String = "STATE_{state}".format({"state": state_name.to_upper()})
	var injection: String = "var {var_name} : {name_class} = {name_class}.new(self)".format({
		"var_name": variable_name,
		"name_class": entity_class_name
	})
	
	## Get all currently lines
	var file = FileAccess.open(states_path, FileAccess.READ)
	var lines: Array[String] = []
	
	while not file.eof_reached():
		lines.append(file.get_line())
	file.close()
	
	## Check already defined FSM variable
	for line in lines:
		if variable_name in line:
			print("Generator: State {name} already defined in FSM. Skipping injection.".format({"name": state_name}))
			return
	
	## Add injection at the end of file
	lines.pop_back()
	lines.append(injection)
	
	## Rewrite file lines
	var write_file = FileAccess.open(states_path, FileAccess.WRITE)
	if write_file:
		for line in lines:
			write_file.store_line(line)
		write_file.close()
	
	var success_msg: String = "[color=cyan]✔ Injected {state} into {path}[/color]"
	print_rich(success_msg.format({"state": state_name, "path": states_path}))


func _template_new_state() -> String:
	return """extends State
class_name {name_class}



var this: {fsm_class}

func setup_state():
	this = (controlled_node as {fsm_class})



func enter():
	pass

func loop():
	pass

func exit():
	pass

	

"""


#
