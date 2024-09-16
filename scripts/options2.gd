extends Node2D

@onready var reload = $Reload/Reload2
@onready var back = $Back/Back2


signal menu
signal next


func _on_reload_mouse_entered():
	reload.modulate = Color.INDIAN_RED


func _on_reload_mouse_exited():
	reload.modulate = Color.WHITE


func _on_reload_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			emit_signal("menu")


func _on_back_mouse_entered():
	back.modulate = Color.INDIAN_RED


func _on_back_mouse_exited():
	back.modulate = Color.WHITE


func _on_back_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			emit_signal("next")
