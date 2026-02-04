@tool
extends AcceptDialog

@export var entity_input: LineEdit
@export var root_directory: String = "res://fsm_entities"

func _ready() -> void:
	register_text_enter(entity_input)
	confirmed.connect(_on_confirmed)
	canceled.connect(hide)
	close_requested.connect(hide)

func _on_confirmed() -> void:
	var base_name: String = entity_input.text.strip_edges()
	
	if base_name.is_empty():
		push_error("FSM Generator: Name cannot be empty.")
		return
	
	_generate_entity_structure(base_name)

func _generate_entity_structure(base_name: String) -> void:
	var snake_name: String = base_name.to_snake_case()
	var pascal_name: String = base_name.to_pascal_case()
	var target_path: String = root_directory.path_join(snake_name)
	
	if DirAccess.dir_exists_absolute(target_path):
		push_error("FSM Generator: Directory already exists at " + target_path + ". Aborting to prevent overwrite.")
		return
	
	var dir_access := DirAccess.open("res://")
	var dir_error := dir_access.make_dir_recursive_absolute(target_path)
	
	if dir_error != OK:
		push_error("FSM Generator: Could not create directory. Error code: " + str(dir_error)) 
		return
	
	var node_script_path: String = "res://fsm_entities/{snake_class_name}/{snake_class_name}.node.gd".format({"snake_class_name": snake_name})
	var node_script_uid: int = ResourceUID.create_id()
	ResourceUID.add_id(node_script_uid, node_script_path)
	
	var scene_uid: int = ResourceUID.create_id()
	
	var template_data: Dictionary = {
		"pascal_class_name": pascal_name,
		"snake_class_name": snake_name,
		"root_path": root_directory,
		"scene_uid": ResourceUID.id_to_text(scene_uid),
		"node_script_uid": ResourceUID.id_to_text(node_script_uid)
	}

	var file_map: Dictionary = {
		snake_name + ".state.idle.gd": _get_template_idle(),
		snake_name + ".state.rest.gd": _get_template_rest(),
		snake_name + ".fsm.gd": _get_template_fsm(),
		snake_name + ".node.gd": _get_template_node(),
		snake_name + ".tscn": _get_template_scene()
	}

	for file_name in file_map:
		_create_generated_file(target_path, file_name, file_map[file_name], template_data)
	
	EditorInterface.get_resource_filesystem().scan()
	hide()



func _create_generated_file(folder: String, file_name: String, content: String, data: Dictionary) -> void:
	var file_path: String = folder.path_join(file_name)
	
	if file_name.ends_with(".tscn"):
		var uid_int: int = ResourceUID.text_to_id(data.scene_uid)
		ResourceUID.add_id(uid_int, file_path)
	
	var file_handler := FileAccess.open(file_path, FileAccess.WRITE)
	if file_handler:
		file_handler.store_string(content.format(data))
		file_handler.close()
	else:
		push_error("FSM Generator: Failed to write file at " + file_path)


## --- Templates --- 


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


var root : Node2D # / Node / CharacterBody2D / Node3D / CharacterBody3D / ...
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


pass

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


@export var root : Node2D : # / Node / CharacterBody2D / Node3D / CharacterBody3D / ...
	set(value):
		{snake_class_name}_fsm.root = value


@export var label : Label :
	set(value):
		{snake_class_name}_fsm.label = value
"""

func _get_template_scene() -> String:
	return """[gd_scene load_steps=2 format=3 uid="{scene_uid}"]

[ext_resource type="Script" uid="{node_script_uid}" path="res://{root_path}/{snake_class_name}/{snake_class_name}.node.gd" id="0_abcdf"]

[node name="{pascal_class_name}" type="Node2D" node_paths=PackedStringArray("root", "label")]
script = ExtResource("0_abcdf")
root = NodePath(".")
label = NodePath("Label")

[node name="Label" type="Label" parent="."]
offset_right = 1.0
offset_bottom = 23.0
"""


pass
