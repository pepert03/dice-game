extends Node2D

@onready var full = $Fullscreen/Full
@onready var exit = $Exit/Label


func _on_fullscreen_mouse_entered():
	full.modulate = Color.INDIAN_RED

func _on_fullscreen_mouse_exited():
	full.modulate = Color.WHITE

func _on_fullscreen_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)



func _on_exit_mouse_entered():
	exit.modulate = Color.INDIAN_RED

func _on_exit_mouse_exited():
	exit.modulate = Color.WHITE

func _on_exit_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			get_tree().quit()
