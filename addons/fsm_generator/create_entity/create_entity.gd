@tool
extends AcceptDialog

# Referencias a nodos
@export var entity_line_edit: LineEdit

# Destino de nuevas entidades
@export var root_path: String = "res://fsm_entities"

func _ready() -> void:
	register_text_enter(entity_line_edit)
	close_requested.connect(_on_close_requested)
	confirmed.connect(_on_confirmed)
	canceled.connect(_on_canceled)

func _on_canceled() -> void:
	hide()

func _on_close_requested() -> void:
	hide()

func _on_confirmed() -> void:
	var raw_name: String = entity_line_edit.text.strip_edges()
	
	if raw_name.is_empty():
		printerr("Error: Por favor, no uses nombres vacíos.")
		return
	
	_generate_structure(raw_name)

## Main
func _generate_structure(base_name: String) -> void:
	var snake_name: String = base_name.to_snake_case()
	var pascal_name: String = base_name.to_pascal_case()
	var full_path: String = root_path.path_join(snake_name)
	
	# 1. Create Directory
	var dir = DirAccess.open("res://")
	var error = dir.make_dir_recursive_absolute(full_path)
	
	if error != OK:
		printerr("Error al crear el directorio. Código: ", error)
		return
	
	# 2. Prepare template data
	var nom_data: Dictionary = {
		"pascal_class_name": pascal_name,
		"snake_class_name": snake_name,
	}
	
	var path_script = "res://fsm_entities/{snake_class_name}/{snake_class_name}.node.gd".format(nom_data)
	var node_script_uid = ResourceUID.create_id()
	ResourceUID.add_id(node_script_uid, path_script)
	
	var scene_uid = ResourceUID.create_id()
	
	var data: Dictionary = {
		"pascal_class_name": pascal_name,
		"snake_class_name": snake_name,
		"root_path": root_path,
		"scene_uid": ResourceUID.id_to_text(scene_uid),
		"node_script_uid": ResourceUID.id_to_text(node_script_uid)
	}

	# 3. Crear Archivos
	# Estado Idle
	_create_file(full_path, snake_name + ".state.idle.gd", _get_template_idle(), data)
	
	# Estado Rest
	_create_file(full_path, snake_name + ".state.rest.gd", _get_template_rest(), data)
	
	# Clase FSM
	_create_file(full_path, snake_name + ".fsm.gd", _get_template_fsm(), data)
	
	# Clase Node (Faltaba en el original, inferido por el nombre)
	_create_file(full_path, snake_name + ".node.gd", _get_template_node(), data)
	
	
	# Escena TSCN
	_create_file(full_path, snake_name + ".tscn", _get_template_scene(), data)
	
	# 4. Actualizar Editor
	EditorInterface.get_resource_filesystem().scan()
	print("Estructura creada con éxito en: ", full_path)
	hide()

# --- Helper ---

func _create_file(folder: String, filename: String, template: String, data: Dictionary) -> void:
	var file_path = folder.path_join(filename)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if filename.contains("tscn"):
		var scene_uid_int = ResourceUID.text_to_id(data.scene_uid)
		ResourceUID.add_id(scene_uid_int, file_path)
	
	if file:
		# Formateamos el string usando los datos proporcionados
		file.store_string(template.format(data))
		file.close()
	else:
		printerr("Error al escribir el archivo: ", file_path)


# --- Templates ---

func _get_template_idle() -> String:
	return """extends State
class_name State{pascal_class_name}Idle


var this: {pascal_class_name}FSM

func config_state():
	this = (controlled_node as {pascal_class_name}FSM)

func enter():
	print("{pascal_class_name} Idle Entered")

func loop():
	this.Idle()

func exit():
	print("{pascal_class_name} Idle Exited")

func change_state_when():
	this.CanRest()

# --- State Methods ---

pass


"""

func _get_template_rest() -> String:
	return """extends State
class_name State{pascal_class_name}Rest


var this: {pascal_class_name}FSM


func config_state():
	this = (controlled_node as {pascal_class_name}FSM)

func enter():
	on_entered.emit()
	print("{pascal_class_name} Rest Entered")

func loop():
	this.Rest()

func exit():
	on_exited.emit()
	print("{pascal_class_name} Rest Exited")

func change_state_when():
	this.CanIdle()


# --- State Methods ---

pass
"""

func _get_template_fsm() -> String:
	return """extends FiniteStateMachine
class_name {pascal_class_name}FSM 


## --- ADD STATES ---


var STATE_REST : State{pascal_class_name}Rest = State{pascal_class_name}Rest.new(self)
var STATE_IDLE : State{pascal_class_name}Idle = State{pascal_class_name}Idle.new(self)


## --- FSM METHODS ---


func execute_ready_methods() -> void:
	change_state(STATE_IDLE)

func execute_input_methods() -> void:
	UpdateInputs()

func execute_physiscs_process_methods() -> void:
	# e.g. move and slide
	pass

func execute_process_methods() -> void:
	pass


## --- SCENE NODES ---


var root : Node # / Node2D / CharacterBody2D / Node3D / CharacterBody3D / ...
var label : Label


## --- Shared Properties and Methods for All Entity States ---


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



func Rest():
	label.text = "Resting"

func Idle():
	label.text = "Idling"
"""

func _get_template_node() -> String:
	return """extends NodeFSM
class_name Node{pascal_class_name}


## --- FSM Setup ---


var {snake_class_name}_fsm : {pascal_class_name}FSM


func _init() -> void:
	object_fsm = {pascal_class_name}FSM.new()
	{snake_class_name}_fsm = object_fsm


## --- Scene Nodes ---


@export var root : Node : # / Node2D / CharacterBody2D / Node3D / CharacterBody3D / ...
	set(value):
		{snake_class_name}_fsm.root = value


@export var label : Label :
	set(value):
		{snake_class_name}_fsm.label = value
"""

func _get_template_scene() -> String:
	return """
[gd_scene load_steps=2 format=3 uid="{scene_uid}"]

[ext_resource type="Script" uid="{node_script_uid}" path="res://{root_path}/{snake_class_name}/{snake_class_name}.node.gd" id="0_abcdf"]

[node name="{pascal_class_name}" type="Node2D" node_paths=PackedStringArray("root", "label")]
script = ExtResource("0_abcdf")
root = NodePath(".")
label = NodePath("Label")

[node name="Label" type="Label" parent="."]
offset_right = 1.0
offset_bottom = 23.0
"""
