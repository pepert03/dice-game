class_name GameManager

extends Node

const DICE = preload("res://scenes/dice.tscn")
const RESTRICTIONS = {
	1: [0,1],2: [1,2],
	3: [0,3],4: [1,4],5: [2,5],
	6: [3,4],7: [4,5],
	8: [3,6],9: [4,7],10: [5,8],
	11: [6,7],12: [7,8]
}

enum MODE {MENU,LEVEL,TITLE,INIT,RULES}

@export var board_node : Board
@export var camera : Camera2D
@export var labels : Node2D
@export var restrictions_node : Node2D

var all_restrictions : Array[Node2D] = []
var board : Array[Cell] = []
var dices : Array[Dice] = []
var game : Game = Game.new()

var started = false
var ended = false
var animating = false
var win = false
var daily = false

var mode = MODE.INIT
var level = 0
var restrictions = []

var height : int
var width : int

func _ready():
	for i in range(9):
		var cell = board_node.get_child(i+2)
		cell.level = i+1
		board.append(cell)
	for i in range(12):
		var rest = restrictions_node.get_child(i)
		all_restrictions.append(rest)
	height = ProjectSettings.get_setting("display/window/size/viewport_height")
	width = ProjectSettings.get_setting("display/window/size/viewport_width")
	Ui.get_child(0).position = Vector2(-150,40)
	Ui.get_child(0).menu.connect(on_menu)
	Ui.get_child(0).next.connect(on_next)

func _process(delta):
	if mode == MODE.LEVEL:
		if started:
			place_dice()
	elif level:
		mode = MODE.LEVEL
		for cell in board:
			var t_cells = get_tree().create_tween()
			t_cells.tween_property(cell.level_sprite,"modulate",Color(0),1)
		var t0 = get_tree().create_tween()
		var t1 = get_tree().create_tween()
		t1.tween_property(labels.get_child(1),"modulate",Color(1,1,1,0),1)
		t1.tween_property(Ui.get_child(0),"position",Vector2(40,40),1)
		t0.tween_property(camera,"position",Vector2(0,0),1).set_trans(Tween.TRANS_SINE)
		t0.tween_callback(factory_dice)


func set_restrictions():
	var n = 12
	var new_rest = []
	var rest_i = [0,1,2,3,4,5,6,7,8,9,10,11]
	rest_i.shuffle()
	for i in range(n):
		new_rest.append(rest_i[i])
	restrictions = new_rest
	for i in range(n):
		var restriction = all_restrictions[new_rest[i]]
		restriction.visible = true
		var a = RESTRICTIONS[new_rest[i]+1][0]
		var b = RESTRICTIONS[new_rest[i]+1][1]
		if game.dices[game.max_board[a]-1] > game.dices[game.max_board[b]-1]:
			restriction.get_child(0).text = ">"
		elif game.dices[game.max_board[a]-1] < game.dices[game.max_board[b]-1]:
			restriction.get_child(0).text = "<"
		else:
			restriction.get_child(0).text = "="

func set_daily():
	daily = true
	var date = Time.get_datetime_dict_from_system()
	var date_string = str(date['year'])
	if date['month'] < 10:
		date_string += '0'
	date_string += str(date['month'])
	if date['day'] < 10:
		date_string += '0'
	date_string += str(date['day'])

	var levels = labels.get_child(1)
	var solution = labels.get_child(2)
	var date_label = labels.get_child(4)
	solution.visible = false
	levels.visible = false
	date_label.modulate = Color("ffffff0b")
	date_label.text = date_string.substr(6,2) + " · "+ date_string.substr(4,2) + " · " + date_string.substr(0,4)
	var collision : CollisionShape2D = solution.get_child(0)
	collision.set_deferred("disabled",true)
	
	game = Game.new(date_string)
	while 0 in game.max_points:
		date_string = str(100000000 + int(date_string))
		game = Game.new(date_string)
	
	level = 9
	set_restrictions()

func set_rules():
	var t0 = get_tree().create_tween()
	t0.tween_property(camera,"position",Vector2(1285,-772.64),1).set_trans(Tween.TRANS_SINE)
	t0.tween_property(Ui.get_child(0),"position",Vector2(40,40),1)
	mode = MODE.MENU


func on_menu():
	if mode == MODE.TITLE:
		return
	if level and not started:
		return
	for dice in dices:
		var tween = get_tree().create_tween()
		tween.tween_property(dice,"scale",Vector2(0,0),0.2)
		tween.tween_callback(dice.queue_free)
	for cell in board:
		cell.under_attack = false
		cell.dice_selected = null
		cell.above = false
		cell.occupied = null
		var t_cells = get_tree().create_tween()
		t_cells.tween_property(cell.level_sprite,"modulate",Color(1,1,1,1),1)
	for restriction in all_restrictions:
		restriction.visible = false

	game = Game.new()
	level = 0
	dices = []
	restrictions = []
	started = false
	ended = false
	win = false
	
	var t1 = get_tree().create_tween()
	var completed = labels.get_child(0)
	var levels = labels.get_child(1)
	var solution = labels.get_child(2)
	var date_label = labels.get_child(4)
	solution.visible = true
	levels.visible = true
	var collision : CollisionShape2D = solution.get_child(0)
	collision.set_deferred("disabled",false)
	
	var t0 = get_tree().create_tween()
	if daily or mode == MODE.MENU:
		mode = MODE.TITLE
		daily = false
		t0.tween_property(camera,"position",Vector2(0,-772.64),1).set_trans(Tween.TRANS_SINE)
		t0.tween_property(Ui.get_child(0), "position", Vector2(-150,40),1)
	else:
		mode = MODE.MENU
		date_label.modulate = Color(1,1,1,0)
		t1.tween_property(completed,"modulate",Color(1,1,1,0),0.5)
		t1.tween_property(levels,"modulate",Color(1,1,1,1),0.5)
		t1.tween_property(completed,"visible",false,0)
		t0.tween_property(camera,"position",Vector2(0,-72),1).set_trans(Tween.TRANS_SINE)
		t0.tween_property(Ui.get_child(0),"position",Vector2(40,40),1)

func on_next():
	if not ended:
		return
	var l = level
	on_menu()
	var levels = labels.get_child(1)
	levels.visible = false
	level = l + 1

func on_previous():
	if game.turn <= (9-level) or win:
		return
	if animating:
		return
	var prev_coord_board = game.order[game.turn-1]
	var prev_dice = dices[game.board[prev_coord_board]-1]
	board[prev_coord_board].occupied = null
	prev_dice.placed = false
	game.previous_board()
	var tween = get_tree().create_tween()
	tween.tween_callback(update_dice.bind(prev_dice.index))
	tween.tween_callback(rearrange)
	tween.tween_callback(prev_dice.undie)


func show_solution():
	if started and animating:
		return
	var correct_turn = 0
	for i in range(9):
		var coord_board = game.max_order[i]
		var coord_dice = game.max_board[coord_board]
		if board[coord_board].occupied and board[coord_board].occupied.index == coord_dice:
			correct_turn += 1
		else:
			break
	var previous_made = game.turn != correct_turn
	while game.turn != correct_turn:
		on_previous()
	if correct_turn < 9:
		if started or game.turn < (9-level):
			if previous_made:
				await get_tree().create_timer(0.2).timeout
			var tween = get_tree().create_tween()
			var coord_board = game.max_order[correct_turn]
			var coord_dice = game.max_board[coord_board]
			move(coord_board,coord_dice,tween)

func move(coord_board,coord_dice, tween : Tween):
	if game.make_move(coord_board,coord_dice):
		var cell = board[coord_board]
		var dice = dices[coord_dice-1]
		cell.occupied = dice
		dice.placed = true

		dice.hover.visible = false
		dice.dice_selected = null
		dice.z_index = 1
		tween.tween_property(dice, "position", cell.position - Vector2(0,3),0.1)
		tween.tween_property(dice, "z_index", 0,0)
		tween.tween_callback(update_dice)
		if game.turn <= (9-level):
			dice.playable = false
			dice.dead.modulate = Color.WHITE
		else:
			tween.tween_callback(rearrange)
			tween.tween_callback(check_win)


func factory_dice():
	for i in range(9):
		var instance = DICE.instantiate()
		instance.dice = game.dices[i]
		instance.rotated = game.orientation[i]
		instance.health = game.max_points[i]
		instance.index = i + 1
		dices.append(instance)
		for cell in board:
			instance.connect("attack",cell._on_dice_attack)
		add_child(instance)
	for i in range(len(dices)):
		dices[i].position = Vector2((width-(len(dices)-1-2*i)*106.6)/2, height * 4/5.0 + 40 + 200)
	
	var tween_level = get_tree().create_tween()
	for i in range(9-level):
		tween_level.tween_callback(show_solution)
	tween_level.tween_callback(subfactory)

func subfactory():
	var dices_left = []
	for dice in dices:
		if not dice.placed:
			dices_left.append(dice)
	var last_tween : Tween
	for i in range(len(dices_left)):
		var start_position = Vector2((width-(len(dices_left)-1-2*i)*106.6)/2,height * 4/5.0 + 40)
		dices_left[i].last_position = start_position
		var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(dices_left[i], "position",start_position,0.2 + 0.1*i)
		last_tween = tween
	last_tween.tween_property(self,"started",true,0)
	last_tween.tween_callback(update_dice)


func place_dice():
	var dice_selected : Dice = dices[0].dice_selected
	for i in range(9):
		var cell = board[i]
		if dice_selected and dice_selected.playable:
			cell.dice_selected = dice_selected
			if not dice_selected.dragging and cell.above and not cell.occupied:
				
				if dice_selected.allowed and game.make_move(i,dice_selected.index):
					dice_selected.position = cell.position - Vector2(0,3)
					cell.occupied = dice_selected
					dice_selected.placed = true
					dice_selected.hover.visible = false
					dice_selected.dice_selected = null
					dice_selected = null
					update_dice()
					rearrange()
					check_win()
		else:
			cell.dice_selected = null
			
	if dice_selected and not dice_selected.dragging:
		dice_selected.z_index = 1
		
		var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(dice_selected, "position",dice_selected.last_position,0.1)
		tween.tween_property(dice_selected, "z_index",0,0)
		dice_selected.not_alowed.scale = Vector2(0,0)
		dice_selected.allowed = true
		for restriction in restrictions:
			var label = all_restrictions[restriction].get_child(0)
			var tween0 = get_tree().create_tween()
			tween0.tween_property(label.get_parent(),"scale",Vector2(1,1),0.1)
		
		dice_selected.dice_selected = null
		dice_selected = null


func update_dice(previous_dice : int = 0):
	for i in range(9):
		var dice : Dice = dices[i]
		var new_health = game.max_points[i] - game.points[i]
		if dice.health >= 0:
			if started:
				if new_health <= 0 and dice.placed:
						new_health = -1
						animating = true
						var tween = get_tree().create_tween()
						tween.tween_property(dice,"position",dice.position + Vector2(0,3),0.5)
						tween.tween_property(self,"animating",false,0)
						dice.die(tween)
				dice.update_health(new_health)
		else:
			if i == previous_dice-1:
				dice.undie()
				dice.update_health(new_health)
			elif new_health > 0:
				animating = true
				var tween = get_tree().create_tween()
				dice.undie(tween)
				tween.tween_property(dice,"position",dice.position - Vector2(0,3),0.2)
				tween.tween_property(self,"animating",false,0)
				dice.update_health(new_health)

func rearrange():
	var dices_left : Array[Dice] = []
	for dice in dices:
		if dice.index not in game.board:
			dices_left.append(dice)
	for i in range(len(dices_left)):
			var new_position = Vector2((width-(len(dices_left)-1-2*i)*106.6)/2,height * 4/5.0 + 40)
			var tween = get_tree().create_tween()
			dices_left[i].z_index = 1
			tween.tween_property(dices_left[i], "position",new_position,0.1)
			tween.tween_property(dices_left[i], "z_index",0,0)
			dices_left[i].last_position = new_position

func check_win():
	for dice in dices:
		if dice.health > 0:
			return false
	win = true
	var t0 = get_tree().create_tween()
	var t1 = get_tree().create_tween()
	t0.tween_property(camera,"position",Vector2(0,-72),1).set_trans(Tween.TRANS_SINE)
	for cell in board:
		var dice = cell.occupied
		t0.tween_property(dice.dead,"modulate",Color(1,1,1,1),0.05)
		t0.tween_property(dice.number,"modulate",Color(1,1,1,1),0.05)
	var completed : Node2D = labels.get_child(0)
	completed.visible = true
	completed.modulate = Color(1,1,1,0)

	if level < 9:
		t1.tween_property(Ui.get_child(0),"position",Vector2(122,40),1)
	t1.tween_property(completed, "modulate", Color(1,1,1,1),0.5)
	t1.tween_property(self,"ended",true,0)



class Game:
	
	var dices = []
	var orientation = []

	var board = [0,0,0,0,0,0,0,0,0]
	var order = [0,0,0,0,0,0,0,0,0]
	var points = [0,0,0,0,0,0,0,0,0]
	var turn = 0

	var max_board = [0,0,0,0,0,0,0,0,0]
	var max_order = [0,0,0,0,0,0,0,0,0]
	var max_points = [0,0,0,0,0,0,0,0,0]

	var board_lives = ["═","═","═","═","═","═","═","═","═"]
	var dices_lives = [0,0,0,0,0,0,0,0,0]

	var dict_points = {
		1: [[4], [4]],
		2: [[0, 8], [2, 6]],
		3: [[0, 4, 8], [2, 4, 6]],
		4: [[0, 2, 6, 8], [0, 2, 6, 8]],
		5: [[0, 2, 4, 6, 8], [0, 2, 4, 6, 8]],
		6: [[0, 2, 3, 5, 6, 8], [0, 1, 2, 6, 7, 8]],
	}
	
	func _init(date_string = ""):
		var rng = RandomNumberGenerator.new()
		if date_string:
			rng.seed = hash(date_string)
		for i in range(9):
			dices.append(rng.randi_range(1,6))
			orientation.append(rng.randi_range(0,1))
		get_goal(rng)

	func get_points(coord):
		var points0 = [0,0,0,0,0,0,0,0,0]
		var dice_coord = self.board[coord] - 1
		var number = self.dices[dice_coord]
		var orientation0 = self.orientation[dice_coord]
		for point_coords in self.dict_points[number][orientation0]:
			var dice_coord1 = self.board[point_coords] - 1
			if dice_coord1 >= 0:
				points0[dice_coord1] += 1
		return points0

	func array_shuffle(rng,array):
		for i in array.size():
			var rand_idx = rng.randi_range(0,array.size()-1)
			if rand_idx == i:
				pass
			else:
				var temp = array[rand_idx]
				array[rand_idx] = array[i]
				array[i] = temp
		return array

	func get_goal(rng):
		var random_order = [0, 1, 2, 3, 4, 5, 6, 7, 8]
		array_shuffle(rng,random_order)
		var random_board = [1, 2, 3, 4, 5, 6, 7, 8, 9]
		array_shuffle(rng,random_board)

		for i in range(9):
			self.board[random_order[i]] = random_board[i]
			var points0 = self.get_points(random_order[i])
			for j in range(9):
				self.points[j] += points0[j]

		self.max_board = board.duplicate()
		self.max_order = random_order.duplicate()
		self.max_points = self.points.duplicate()
		self.board = [0,0,0,0,0,0,0,0,0]
		self.order = [0,0,0,0,0,0,0,0,0]
		self.points = [0,0,0,0,0,0,0,0,0]
		self.dices_lives = self.max_points.duplicate()

	func update_lives(coord_dice, coord_board):
		for i in range(9):
			if self.board[i] != 0:
				var updated = (self.max_points[self.board[i] - 1] - self.points[self.board[i] - 1])
				if updated == 0:
					self.board_lives[i] = "═"
				elif updated < 0:
					self.board_lives[i] = "x"
				else:
					self.board_lives[i] = updated

				if i == coord_board:
					self.dices_lives[coord_dice - 1] = "═"

	func make_move(coord_board, coord_dice):
		self.board[coord_board] = coord_dice
		self.order[self.turn] = coord_board

		var points0 = self.get_points(coord_board)
		for i in range(9):
			self.points[i] += points0[i]

		self.update_lives(coord_dice, coord_board)
		self.turn += 1
		
		if is_valid():
			return true
		else:
			previous_board()
			return false
	
	func is_valid():
		for cell in board_lives:
			if str(cell) == "x":
				return false
		return true

	func previous_board():
		if self.turn == 0:
			return
		self.turn -= 1
		var coord_board = self.order[self.turn]
		var coord_dice = self.board[coord_board]
		self.board[coord_board] = coord_dice
		var points0 = self.get_points(coord_board)
		for i in range(9):
			self.points[i] -= points0[i]

		self.update_lives(coord_dice, coord_board)
		self.dices_lives[coord_dice - 1] = self.max_points[coord_dice - 1]
		self.board_lives[coord_board] = "═"

		self.board[coord_board] = 0
		self.order[self.turn] = 0

	func restart():
		self.board = [0,0,0,0,0,0,0,0,0]
		self.order = [0,0,0,0,0,0,0,0,0]
		self.points = [0,0,0,0,0,0,0,0,0]
		self.board_lives = ["═","═","═","═","═","═","═","═","═"]
		self.dices_lives = self.max_points.duplicate()
		self.turn = 0
