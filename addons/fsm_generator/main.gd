@tool
extends EditorPlugin

var tool_create_entity = preload("res://addons/fsm_generator/create_entity/create_entity.tscn")
var create_entity_popup : AcceptDialog

var tool_create_entity_state = preload("res://addons/fsm_generator/create_entity_state/create_entity_state.tscn")
var create_entity_state_popup : AcceptDialog


func _enter_tree() -> void:
	add_tool_menu_item("FSM Script Generator - Create Entity", _open_window_Create_Entity)
	add_tool_menu_item("FSM Script Generator - Create Entity State", _open_window_Create_Entity_State)

func _exit_tree() -> void:
	remove_tool_menu_item("FSM Script Generator - Create Entity")
	remove_tool_menu_item("FSM Script Generator - Create Entity State")
	if create_entity_popup:
		create_entity_popup.free()
	if create_entity_state_popup:
		create_entity_state_popup.free()

func _open_window_Create_Entity()-> void:
	create_entity_popup = tool_create_entity.instantiate()
	get_editor_interface().get_base_control().add_child(create_entity_popup)
	create_entity_popup.popup_centered()

func _open_window_Create_Entity_State()-> void:
	create_entity_state_popup = tool_create_entity_state.instantiate()
	get_editor_interface().get_base_control().add_child(create_entity_state_popup)
	create_entity_state_popup.popup_centered()
