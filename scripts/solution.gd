extends Area2D

@onready var solution = $Hint
@onready var game_manager = %GameManager

func _on_mouse_entered():
	solution.modulate = Color.WHITE

func _on_mouse_exited():
	solution.modulate = Color("ffffff32")

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if game_manager.started:
				game_manager.show_solution()
