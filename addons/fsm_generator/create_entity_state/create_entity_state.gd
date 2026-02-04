@tool
extends AcceptDialog

@export var entity_input: LineEdit
@export var state_name_input: LineEdit
@export_dir var root_dir: String = "res://fsm_entities"

func _ready() -> void:
	register_text_enter(entity_input)
	register_text_enter(state_name_input)
	confirmed.connect(_on_confirmed)
	canceled.connect(hide)
	close_requested.connect(hide)

## Main
func _on_confirmed() -> void:
	var entity: String = entity_input.text.strip_edges().to_snake_case()
	var state_name: String = state_name_input.text.strip_edges().to_snake_case()
	
	if entity.is_empty() or state_name.is_empty():
		printerr("Generator: Please fill in both fields.")
		return
	
	_process_state_generation(entity, state_name)
	EditorInterface.get_resource_filesystem().scan()


## --- Methods ---


func _process_state_generation(entity: String, state: String) -> void:
	var folder_path: String = root_dir.path_join(entity)
	var fsm_script_path: String = folder_path.path_join("{entity}.fsm.gd".format({"entity": entity}))
	var new_state_path: String = folder_path.path_join("{entity}.state.{state}.gd".format({"entity": entity, "state": state}))
	
	if FileAccess.file_exists(new_state_path):
		printerr("Generator: State file already exists at {path}. Aborting.".format({"path": new_state_path}))
		return
	
	_create_state_file(new_state_path, entity, state)
	_inject_state_into_fsm(fsm_script_path, entity, state)

func _create_state_file(path: String, entity_name: String, state_name: String) -> void:
	var entity_class: String = "State{entity}{state}".format({
		"entity": entity_name.to_pascal_case(),
		"state": state_name.to_pascal_case()
	})
	
	var template: String = _template_new_state()
	var content: String = template.format({
		"class_name": entity_class,
		"fsm_class": entity_name.to_pascal_case() + "FSM"
	})

	var file = FileAccess.open(path, FileAccess.READ_WRITE)
	if file:
		file.store_string(content)
		file.close()

func _inject_state_into_fsm(fsm_path: String, entity_name : String, state_name: String) -> void:
	if not FileAccess.file_exists(fsm_path):
		printerr("Generator: FSM script not found at {path}".format({"path": fsm_path}))
		return

	var file = FileAccess.open(fsm_path, FileAccess.READ_WRITE)
	var lines: Array[String] = []
	while not file.eof_reached():
		lines.append(file.get_line())
	file.close()
	
	var entity_class_name: String = "State{entity}{state}".format({
		"entity": entity_name.to_pascal_case(),
		"state": state_name.to_pascal_case()
	})
	
	var variable_name: String = "STATE_{state}".format({"state": state_name.to_upper()})
	var injection: String = "var {var_name} : {class_name} = {class_name}.new(self)".format({
		"var_name": variable_name,
		"class_name": entity_class_name
	})
	
	for line in lines:
		if variable_name in line:
			print("Generator: State {name} already defined. Skipping.".format({"name": state_name}))
			return
	
	var target_index: int = 7 
	if lines.size() > target_index:
		lines.insert(target_index, injection)
	else:
		lines.append(injection)
	
	var write_file = FileAccess.open(fsm_path, FileAccess.READ_WRITE)
	if write_file:
		for line in lines:
			write_file.store_line(line)
		write_file.close()
	
	
	var success_msg: String = "[color=cyan]✔ Injected {state} into {path}[/color]"
	print_rich(success_msg.format({"state": state_name, "path": fsm_path}))





func _template_new_state():
	return """extends State
class_name {class_name}



var this: {fsm_class}

func config_state():
	this = (controlled_node as {fsm_class})



func enter():
	pass

func loop():
	pass

func exit():
	pass



func change_state_when():
	pass


# --- State Methods ---


pass

"""
