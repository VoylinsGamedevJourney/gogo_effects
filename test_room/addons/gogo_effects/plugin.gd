@tool
class_name GoGoEffectsServer
extends EditorPlugin
## GoGoEffectsServer is only used for adding the node to the node list.



func _enter_tree() -> void:
	add_custom_type(
			"VideoPlayback", "Control",
			load("res://addons/gogo_effects/gogo_efects.gd"),
			load("res://addons/gogo_effects/icon.svg"))


func _exit_tree() -> void:
	remove_custom_type("GoGoEffects")
