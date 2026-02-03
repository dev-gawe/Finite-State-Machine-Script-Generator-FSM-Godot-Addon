@tool
extends EditorPlugin

var entity_tool_menu_scene = preload("res://addons/fsm_generator/create_entity/create_entity.tscn")
var entity_tool_popup : AcceptDialog


func _enter_tree() -> void:
	add_tool_menu_item("FSM Script Generator - Create Entity", _open_window_Create_Entity)

func _exit_tree() -> void:
	remove_tool_menu_item("FSM Script Generator - Create Entity")
	if entity_tool_popup:
		entity_tool_popup.free()

func _open_window_Create_Entity()-> void:
	entity_tool_popup = entity_tool_menu_scene.instantiate()
	get_editor_interface().get_base_control().add_child(entity_tool_popup)
	entity_tool_popup.popup_centered()
