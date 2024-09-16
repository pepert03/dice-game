class_name Dice

extends Node2D

@onready var shadow = $Sprites/Shadow
@onready var number = $Sprites/Number
@onready var health_sprite = $Sprites/Health
@onready var hover = $Sprites/hover
@onready var dead = $Sprites/Dead
@onready var not_alowed : Label = $Sprites/x


@export_range(1,6) var dice : int
@export_range(0,1) var rotated : int
@export_range(0,9) var health : int


var playable = true
var allowed = true
var placed = false
var dragging = false
var mouse_hover = false
var hovering = false


static var dice_selected : Dice = null
var last_position : Vector2
var index : int


signal attack(a)

const PATTERNS = {
			1: [[4], [4]],
			2: [[0, 8], [2, 6]],
			3: [[0, 4, 8], [2, 4, 6]],
			4: [[0, 2, 6, 8], [0, 2, 6, 8]],
			5: [[0, 2, 4, 6, 8], [0, 2, 4, 6, 8]],
			6: [[0, 2, 3, 5, 6, 8], [0, 1, 2, 6, 7, 8]],
		}

# Called when the node enters the scene tree for the first time.
func _ready():
	instanciate_dice()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not placed:
		if dragging:
			position = get_global_mouse_position()
		if (mouse_hover and not dice_selected and not hovering) or dice_selected == self:
			hovering = true
			hover.visible = true
			health_sprite.get_child(1).play("float")
		if not mouse_hover and hovering:
			hovering = false
			hover.visible = false
			health_sprite.get_child(1).play("RESET")

func instanciate_dice():
	play_number()
	number.rotate(rotated * PI / 2)
	health_sprite.get_child(0).text = str(health)
	scale = Vector2(1.3,1.3)

func die(tween : Tween):
	shadow.visible = false
	health_sprite.visible = false
	number.scale = Vector2(1.035,1.035)
	
	var tween2 = get_tree().create_tween()
	tween.tween_callback(play_dead)
	tween.tween_property(dead,"modulate",Color(0.5,0.5,0.5,0.5),0.1)
	tween2.tween_property(number,"modulate",Color(1,1,1,0.2),0.5)

	health_sprite.get_child(1).play("RESET")

func play_dead():
	number.play("0")
func play_number():
	number.play(str(dice))

func undie(tween : Tween = get_tree().create_tween()):
	shadow.visible = true
	health_sprite.visible = true
	number.scale = Vector2(1,1)
	
	var tween2 = get_tree().create_tween()
	if playable:
		tween.tween_property(dead,"modulate",Color(1,1,1,0),0.1)
	else:
		tween.tween_property(dead,"modulate",Color(1,1,1,1),0.1)
	tween.tween_callback(play_number)
	tween2.tween_property(number,"modulate",Color(1,1,1,1),0.1)
	health_sprite.get_child(1).play("float")


func update_health(new_health):
	health = new_health
	health_sprite.get_child(0).text = str(health)


func _on_mouse_entered():
	mouse_hover = true

func _on_mouse_exited():
	mouse_hover = false

func _on_input_event(viewport, event, shape_idx):
	if not placed:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					dragging = true
					dice_selected = self
					z_index = 1
					scale = Vector2(1.5,1.5)
					attack.emit(PATTERNS[dice][rotated])
				else:
					if dragging:
						dragging = false
						z_index = 0
						scale = Vector2(1.3,1.3)
