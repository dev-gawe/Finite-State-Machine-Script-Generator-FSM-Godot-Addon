@tool
extends AcceptDialog

const STATE_TEMPLATE := """extends State
class_name {name_class}


var this: {entity_name}FSM

func config_state():
	this = (controlled_node as {entity_name}FSM)

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

const INJECTION_TEMPLATE := "var {var_name}: {name_class} = {name_class}.new(self)"

# --- Exports ---

@export var entity_input: LineEdit
@export var state_name_input: LineEdit

@export_dir var root_directory: String = "res://fsm_entities"


# --- Built-in Methods ---

func _ready() -> void:
	# Connect dialog signals
	confirmed.connect(_on_confirmed)
	canceled.connect(_on_hide_requested)
	close_requested.connect(_on_hide_requested)
	
	# Register inputs for "Enter" key support
	register_text_enter(entity_input)
	register_text_enter(state_name_input)


# --- Signal Handlers ---

func _on_hide_requested() -> void:
	hide()


func _on_confirmed() -> void:
	var entity: String = entity_input.text.strip_edges().to_snake_case()
	var state: String = state_name_input.text.strip_edges().to_snake_case()
	
	if entity.is_empty() or state.is_empty():
		printerr("FSM Generator: Validation failed. Both Entity and State names are required.")
		return
	
	_generate_fsm_components(entity, state)
	EditorInterface.get_resource_filesystem().scan()


# --- Logic ---

func _generate_fsm_components(entity: String, state: String) -> void:
	var folder_path: String = root_directory.path_join(entity)
	
	# Ensure directory exists
	if not DirAccess.dir_exists_absolute(folder_path):
		DirAccess.make_dir_recursive_absolute(folder_path)
	
	var fsm_script_path: String = folder_path.path_join(entity + ".fsm.gd")
	var state_script_path: String = folder_path.path_join(entity + ".state." + state + ".gd")
	
	var pascal_entity: String = entity.to_pascal_case()
	var pascal_state: String = state.to_pascal_case()
	var state_class_name: String = "State" + pascal_entity + pascal_state

	_create_state_file(state_script_path, pascal_entity, state_class_name)
	_inject_state_to_fsm(fsm_script_path, state, state_class_name)


func _create_state_file(path: String, entity_name: String, name_class: String) -> void:
	var content := STATE_TEMPLATE.format({
		"name_class": name_class,
		"entity_name": entity_name
	})

	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
		print("FSM Generator: Created state file at ", path)


func _inject_state_to_fsm(fsm_path: String, state_name: String, name_class: String) -> void:
	if not FileAccess.file_exists(fsm_path):
		printerr("FSM Generator: FSM script not found. Skipping injection: ", fsm_path)
		return
	
	# Load existing lines
	var file := FileAccess.open(fsm_path, FileAccess.READ)
	var lines: Array[String] = []
	while not file.eof_reached():
		lines.append(file.get_line())
	file.close()
	
	var var_name := "STATE_" + state_name.to_upper()
	var injection_code := INJECTION_TEMPLATE.format({
		"var_name": var_name,
		"name_class": name_class
	})

	# Prevent duplicate injections
	for line in lines:
		if var_name in line:
			print("FSM Generator: State already exists in FSM. Skipping.")
			return
	
	# Insert injection (defaulting to line 7 or end of file)
	var target_index: int = 7
	if lines.size() > target_index:
		lines.insert(target_index, injection_code)
	else:
		lines.append(injection_code)
	
	# Save modified file
	var write_file := FileAccess.open(fsm_path, FileAccess.WRITE)
	if write_file:
		for line in lines:
			write_file.store_line(line)
		write_file.close()
		print_rich("[color=cyan]✔ Successfully injected %s into FSM[/color]" % state_name)
