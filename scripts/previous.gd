extends Area2D

@onready var previous = $Previous

@onready var game_manager = %GameManager

func _on_mouse_entered():
	previous.modulate = Color.WHITE

func _on_mouse_exited():
	previous.modulate = Color("ffffff32")

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			game_manager.on_previous()
