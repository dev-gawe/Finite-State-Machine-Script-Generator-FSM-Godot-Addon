@tool
extends AcceptDialog

func _ready():
	close_requested.connect(_on_close_requested)
	confirmed.connect(_on_confirmed)
	canceled.connect(_on_canceled)

func _on_close_requested():
	hide()

#func _on_confirmed():
	#hide()

func _on_canceled():
	hide()
""" """

@onready var name_input : LineEdit = $VBoxContainer/HBoxContainer/LineEdit

func _on_confirmed():
	var root_path = "res://entities" # Carpeta principal
	var subfolder_name = name_input.text.strip_edges().to_snake_case() # Nombre desde el formulario
	
	if subfolder_name == "":
		printerr("Error: El nombre no puede estar vacío")
		return

	var full_path = root_path.path_join(subfolder_name)
	
	var dir = DirAccess.open("res://")
	
	# make_dir_recursive crea la carpeta padre y la subcarpeta si no existen
	var error = dir.make_dir_recursive_absolute(full_path)
	
	if error == OK:
		create_entity_template_idle_state(full_path, subfolder_name)
		create_entity_template_rest_state(full_path, subfolder_name)
		
		create_entity_template_nodefsm(full_path, subfolder_name)
		create_entity_template_classfsm(full_path, subfolder_name)
		
		# ¡Importante! Avisar a Godot que hay archivos nuevos
		EditorInterface.get_resource_filesystem().scan()
		print("Estructura creada con éxito en: ", full_path)
	else:
		printerr("Error al crear el directorio. Código: ", error)


func create_entity_template_idle_state(path: String, base_name: String):
	var pascal_name = base_name.to_pascal_case()
	var snake_name = base_name.to_snake_case()
	
	var script_path = path.path_join(base_name + ".state.idle.gd")
	
	var template = """class_name State{pascal_class_name}Idle extends State


var this: {pascal_class_name}FSM

func config_state():
	this = (controlled_node as {pascal_class_name}FSM)

func enter():
	this.Stop()

func loop():
	this.Idle()

func exit():
	pass

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
		# .format(data) reemplaza los {keys} por sus valores
		file.store_string(template.format(data))
		file.close()


func create_entity_template_rest_state(path: String, base_name: String):
	var pascal_name = base_name.to_pascal_case()
	var snake_name = base_name.to_snake_case()
	
	var script_path = path.path_join(base_name + ".state.rest.gd")
	
	var template = """class_name State{pascal_class_name}Rest extends State


var this: {pascal_class_name}FSM

func config_state():
	this = (controlled_node as {pascal_class_name}FSM)

func enter():
	this.Stop()

func loop():
	this.Idle()

func exit():
	pass

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
		# .format(data) reemplaza los {keys} por sus valores
		file.store_string(template.format(data))
		file.close()



func create_entity_template_nodefsm(path: String, base_name: String):
	var pascal_name = base_name.to_pascal_case()
	var snake_name = base_name.to_snake_case()
	
	var script_path = path.path_join(base_name + ".node.gd")
	
	var template = """extends NodeFSM
class_name Node{pascal_class_name}

## TODO attach this node on your own {pascal_class_name}.tscn

var {snake_class_name}_fsm : {pascal_class_name}FSM

func _init() -> void:
	object_fsm = {pascal_class_name}FSM.new()
	{snake_class_name}_fsm = object_fsm

## TODO New Nodes

@export var sprites : AnimatedSprite2D :
	set(value):
		{snake_class_name}_fsm.sprites = value


@export var audio2d : AudioStreamPlayer2D :
	set(value):
		{snake_class_name}_fsm.audio2d = value
"""
	
	var data = {
		"pascal_class_name": pascal_name,
		"snake_class_name": snake_name,
		"original_name": base_name
	}
	
	var file = FileAccess.open(script_path, FileAccess.WRITE)
	if file:
		# .format(data) reemplaza los {keys} por sus valores
		file.store_string(template.format(data))
		file.close()


func create_entity_template_classfsm(path: String, base_name: String):
	var pascal_name = base_name.to_pascal_case()
	var snake_name = base_name.to_snake_case()
	
	var script_path = path.path_join(base_name + ".fsm.gd")
	
	var template = """class_name {pascal_class_name}FSM extends FiniteStateMachine


func ready_fsm() -> void:
	change_state(STATE_IDLE)


func execute_process_methods() -> void:
	UpdateInputs()


func execute_physiscs_process_methods():
	pass
	# Example: Here, you can character.move_and_slide() after current_state_machine loop runs
	#     or any command (methods/setters)


#var character : CharacterBody2D
var sprites : AnimatedSprite2D
var audio2d : AudioStreamPlayer2D


## --- ADD STATES ---


var STATE_IDLE : State{pascal_class_name}Idle = State{pascal_class_name}Idle.new(self)
var STATE_REST : State{pascal_class_name}Rest = State{pascal_class_name}Rest.new(self)


## --- Properties and Methods For All Object States ---

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


"""
	
	var data = {
		"pascal_class_name": pascal_name,
		"snake_class_name": snake_name,
		"original_name": base_name
	}
	
	var file = FileAccess.open(script_path, FileAccess.WRITE)
	if file:
		# .format(data) reemplaza los {keys} por sus valores
		file.store_string(template.format(data))
		file.close()
