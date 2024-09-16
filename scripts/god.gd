#@tool
class_name  Board
extends Node2D

const CELL_SCENE = preload("res://scenes/cell.tscn")
const CELL = preload("res://assets/sprites/pngs/1.png")
const SCALE = 0.185

func _ready():
	pass
	#if Engine.is_editor_hint():
		#var HEIGHT = ProjectSettings.get_setting("display/window/size/viewport_height")
		#var WIDTH = ProjectSettings.get_setting("display/window/size/viewport_width")
		#var CELLH = CELL.get_height() * SCALE
		#var CELLW = CELL.get_width() * SCALE
#
		#for i in range(9):
			#var cell = CELL_SCENE.instantiate()
			#var x_cell = WIDTH/2 - CELLW - 25 + (i%3) * (CELLW + 25)
			#var y_cell = HEIGHT * 2/5 - CELLW -25 + int(i/3) * (CELLW + 25)
			#cell.position = Vector2(x_cell,y_cell)
			#add_child(cell)
			#cell.owner = get_parent()
			#cell.name = "Cell"+str(i)

func _process(delta):
	pass
