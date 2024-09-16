class_name Cell
extends Area2D

enum MODE {MENU,LEVEL}

@export var cellindex : int
@onready var sprite = $"1"
@onready var sprite2 = $"2"
@onready var level_sprite = $"2/Level"

@onready var game_manager = %GameManager

var under_attack = false
static var dice_selected : Dice = null
var above = false
var occupied : Dice = null
var level : int

# Called when the node enters the scene tree for the first time.
func _ready():
	level_sprite.text = str(level)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dice_selected and under_attack:
		if occupied:
			if occupied.health <= 0:
				var tween = get_tree().create_tween()
				tween.tween_property(occupied.not_alowed, "scale",Vector2(1.3,1.3),0.1)
		sprite.modulate = Color(1,0,0,0.3)
	else:
		if occupied:
			var tween = get_tree().create_tween()
			tween.tween_property(occupied.not_alowed, "scale",Vector2(0,0),0.1)
		under_attack = false
		sprite.modulate = Color(0,0,0,0.17)
	
	if above and ((dice_selected and not occupied) or game_manager.mode == MODE.MENU):
		sprite2.modulate = Color(1,1,1,0.2)
	else:
		sprite2.modulate = Color(1,1,1,0.10)


func check_restrictions():
	var placeable = true
	for restriction in game_manager.restrictions:
		var label = game_manager.all_restrictions[restriction].get_child(0)
		var a = game_manager.RESTRICTIONS[restriction+1][0]
		var b = game_manager.RESTRICTIONS[restriction+1][1]
		
		var dice_a = null
		var dice_b = null
		var other = -1
		
		if cellindex == a:
			dice_a = dice_selected.dice
			other = b
		elif cellindex == b:
			dice_b = dice_selected.dice
			other = a
		if other != -1 and game_manager.board[other].occupied:
			if other == a:
				dice_a = game_manager.board[other].occupied.dice
			else:
				dice_b = game_manager.board[other].occupied.dice
			if (label.text == ">" and dice_a <= dice_b) \
			or (label.text == "<" and dice_a >= dice_b) \
			or (label.text == "=" and dice_a != dice_b):
				placeable = false
				var tween = get_tree().create_tween()
				tween.tween_property(label.get_parent(),"scale",Vector2(1.6,1.6),0.1)
	return placeable


func _on_dice_attack(attack):
	for index in attack:
		if cellindex == index:
			under_attack = true

func _on_mouse_entered():
	if dice_selected or game_manager.mode == MODE.MENU:
		above = true
		if  not occupied:
			if under_attack and dice_selected.health <= 0 or not check_restrictions():
				var tween = get_tree().create_tween()
				dice_selected.allowed = false
				tween.tween_property(dice_selected.not_alowed, "scale",Vector2(1.3,1.3),0.1)

func _on_mouse_exited():
	above = false
	if dice_selected:
		var tween = get_tree().create_tween()
		dice_selected.allowed = true
		tween.tween_property(dice_selected.not_alowed, "scale",Vector2(0,0),0.1)
		for restriction in game_manager.restrictions:
			if cellindex in game_manager.RESTRICTIONS[restriction+1]:
				var label = game_manager.all_restrictions[restriction].get_child(0)
				var tween0 = get_tree().create_tween()
				tween0.tween_property(label.get_parent(),"scale",Vector2(1,1),0.1)


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if game_manager.mode == MODE.MENU:
				game_manager.level = level
