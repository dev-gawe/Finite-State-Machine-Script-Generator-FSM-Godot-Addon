@tool
extends AcceptDialog

@export var EntityLineEdit : LineEdit

func _ready():
	register_text_enter(EntityLineEdit)
	close_requested.connect(_on_close_requested)
	confirmed.connect(_on_confirmed)
	canceled.connect(_on_canceled)

func _on_canceled():
	hide()

func _on_close_requested():
	hide()

func _on_confirmed():
	
	var subfolder_name = (
		EntityLineEdit.
		text.
		strip_edges().
		to_snake_case()
	)
	
	if subfolder_name == "":
		printerr("Error: Please, no empty names")
		return
	
	var root_path = "res://fsm_entities"
	var full_path = root_path.path_join(subfolder_name)
	
	var dir = DirAccess.open("res://")
	var error = dir.make_dir_recursive_absolute(full_path)
	
	if error != OK:
		printerr("Error al crear el directorio. Código: ", error)
		return
	
	if error == OK:
		
		create_entity_template_idle_state(full_path, subfolder_name)
		create_entity_template_rest_state(full_path, subfolder_name)
		
		create_entity_template_classfsm(full_path, subfolder_name)
		create_entity_template_nodefsm(full_path, subfolder_name)
		
		create_entity_template_scene(full_path, subfolder_name)
		
		# Actualizar en godot archivos nuevos
		EditorInterface.get_resource_filesystem().scan()
		print("Estructura creada con éxito en: ", full_path)
		return






func create_entity_template_idle_state(path: String, base_name: String):
	var pascal_name = base_name.to_pascal_case()
	var snake_name = base_name.to_snake_case()
	
	var script_path = path.path_join(base_name + ".state.idle.gd")
	
	var template = """extends State
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
	
	var data = {
		"pascal_class_name": pascal_name,
		"snake_class_name": snake_name,
		"original_name": base_name
	}
	
	var file = FileAccess.open(script_path, FileAccess.WRITE)
	if file:
		file.store_string(template.format(data))
		file.close()






func create_entity_template_rest_state(path: String, base_name: String):
	var pascal_name = base_name.to_pascal_case()
	var snake_name = base_name.to_snake_case()
	
	var script_path = path.path_join(base_name + ".state.rest.gd")
	
	var template = """extends State
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
	
	var data = {
		"pascal_class_name": pascal_name,
		"snake_class_name": snake_name,
		"original_name": base_name
	}
	
	var file = FileAccess.open(script_path, FileAccess.WRITE)
	if file:
		file.store_string(template.format(data))
		file.close()






func create_entity_template_classfsm(path: String, base_name: String):
	var pascal_name = base_name.to_pascal_case()
	var snake_name = base_name.to_snake_case()
	
	var script_path = path.path_join(base_name + ".fsm.gd")
	
	var template = """extends FiniteStateMachine
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
	
	var data = {
		"pascal_class_name": pascal_name,
		"snake_class_name": snake_name,
		"original_name": base_name
	}
	
	var file = FileAccess.open(script_path, FileAccess.WRITE)
	if file:
		file.store_string(template.format(data))
		file.close()






func create_entity_template_nodefsm(path: String, base_name: String):
	var pascal_name = base_name.to_pascal_case()
	var snake_name = base_name.to_snake_case()
	
	var script_path = path.path_join(base_name + ".node.gd")
	
	var template = """extends NodeFSM
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
	
	var data = {
		"pascal_class_name": pascal_name,
		"snake_class_name": snake_name,
		"original_name": base_name
	}
	
	var file = FileAccess.open(script_path, FileAccess.WRITE)
	if file:
		file.store_string(template.format(data))
		file.close()






func create_entity_template_scene(path: String, base_name: String):
	var pascal_name = base_name.to_pascal_case()
	var snake_name = base_name.to_snake_case()
	
	var pre_data = {
		"pascal_class_name": pascal_name,
		"snake_class_name": snake_name,
		"original_name": base_name
	}
	
	var new_uid = ResourceUID.create_id()
	
	var script_uid = ResourceUID.create_id()
	var path_script = "res://fsm_entities/{snake_class_name}/{snake_class_name}.node.gd".format(pre_data)
	ResourceUID.add_id(script_uid, path_script)
	
	
	var post_data = {
		"pascal_class_name": pascal_name,
		"snake_class_name": snake_name,
		"original_name": base_name,
		"new_uid": new_uid,
		"script_uid": ResourceUID.id_to_text(script_uid)
	}
	
	var template = """
[gd_scene load_steps=2 format=3 uid="uid://{new_uid}"]

[ext_resource type="Script" uid="{script_uid}" path="res://fsm_entities/{snake_class_name}/{snake_class_name}.node.gd" id="0_abcdf"]

[node name="{pascal_class_name}" type="Node2D" node_paths=PackedStringArray("root", "label")]
script = ExtResource("0_abcdf")
root = NodePath(".")
label = NodePath("Label")

[node name="Label" type="Label" parent="."]
offset_right = 1.0
offset_bottom = 23.0

"""
	
	var scene_path = path.path_join(base_name + ".tscn")
	var file = FileAccess.open(scene_path, FileAccess.WRITE)
	ResourceUID.add_id(new_uid, scene_path)
	if file:
		file.store_string(template.format(post_data))
		file.close()
	
