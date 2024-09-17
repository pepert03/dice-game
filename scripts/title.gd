extends Node2D

@onready var game_manager = %GameManager

@onready var tutorial = $Tutorial
@onready var daily = $Daily
@onready var level = $Level


func _on_level_mouse_entered():
	level.get_child(0).visible = true

func _on_level_mouse_exited():
	level.get_child(0).visible = false

func _on_level_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			game_manager.mode = game_manager.MODE.INIT
			game_manager.on_menu()



func _on_daily_mouse_entered():
	daily.get_child(0).visible = true

func _on_daily_mouse_exited():
	daily.get_child(0).visible = false

func _on_daily_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			game_manager.set_daily()




func _on_tutorial_mouse_entered():
	tutorial.get_child(0).visible = true

func _on_tutorial_mouse_exited():
	tutorial.get_child(0).visible = false

func _on_tutorial_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			game_manager.mode = game_manager.MODE.RULES
			game_manager.set_rules()
