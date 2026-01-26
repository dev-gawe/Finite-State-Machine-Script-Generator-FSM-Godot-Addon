@tool
extends EditorPlugin

var entity_tool_menu_scene = preload("res://addons/ScriptedFSM/create_entity.tscn")
var entity_tool_popup : AcceptDialog


func _enter_tree() -> void:
	add_tool_menu_item("Scripted FSM - Create Entity", _open_window)
	#add_tool_menu_item("Scripted FSM - Create State", _open_window)

func _exit_tree() -> void:
	remove_tool_menu_item("Create FSM")
	if entity_tool_popup:
		entity_tool_popup.free()

func _open_window()-> void:
	entity_tool_popup = entity_tool_menu_scene.instantiate()
	get_editor_interface().get_base_control().add_child(entity_tool_popup)
	entity_tool_popup.popup_centered()
