extends Control

# --- TEXTURES (replace paths with your own as needed) ---
var tex_x = preload("res://Assets/Images/X.png")
var tex_o = preload("res://Assets/Images/O.png")
var tex_default = preload("res://Assets/Images/XO.png")

# --- UI REFERENCES ---
@onready var turn_label: Label = $Turn
@onready var round_label: Label = $Round
@onready var grid: GridContainer = $GridContainer
@onready var audio_player: AudioStreamPlayer = $playerSound

# Difficulty: 1–10 (higher = smarter, less random)
@export var ai_difficulty := 4

# --- GAME STATE ---
var board := [
	["", "", ""],
	["", "", ""],
	["", "", ""]
]

var player_symbol := "X"
var ai_symbol := "O"
var player_turn := true
var game_over := false

var round_count := 0
var max_rounds := 3   # set to 1 if you want single-round only

func _ready() -> void:
		# Increase round count when entering this screen
	GlobalState.round += 1

	# Determine which buttons should appear
	if GlobalState.round >= 3:
		# Round 3 = Final → Show Play Again
		$play_again.visible = true
		$next_game.visible = false
	else:
		# Round 1 or 2 → Show Next Game
		$play_again.visible = false
		$next_game.visible = true
		
	$Game_Round.text = "Round: " + str(GlobalState.round) + "\nTTT"
	reset_board()
	update_turn_label()
	update_round_label()

	for i in range(9):
		var button := grid.get_child(i)
		button.connect("pressed", Callable(self, "_on_tile_pressed").bind(i))


# ---------------------------
# BUTTON: PLAY AGAIN
# Only appears when round == 3
# ---------------------------
func _on_play_again_pressed() -> void:
	# Reset session
	GlobalState.round = 0
	GlobalState.current_score = 0
	GlobalState.previous_games.clear()

	# Start new random run
	GlobalState.load_single_game()

# ---------------------------
# BUTTON: NEXT GAME
# Only appears when round < 3
# ---------------------------
func _on_next_game_pressed() -> void:
	if GlobalState.round < 3:
		GlobalState.load_single_game()

# -----------------------------------------------------
# RESET BOARD
# -----------------------------------------------------
func reset_board() -> void:
	for r in range(3):
		for c in range(3):
			board[r][c] = ""
			var button := grid.get_child(r * 3 + c)
			button.texture_normal = tex_default
			button.disabled = false

	game_over = false
	player_turn = true
	update_turn_label()


# -----------------------------------------------------
# PLAYER MOVE
# -----------------------------------------------------
func _on_tile_pressed(index: int) -> void:
	if not player_turn or game_over:
		return

	var row := index / 3
	var col := index % 3

	if board[row][col] != "":
		return


	board[row][col] = player_symbol
	var btn := grid.get_child(index)
	btn.texture_normal = tex_x
	btn.disabled = true

	if not check_winner():
		player_turn = false
		update_turn_label()
		ai_move()


# -----------------------------------------------------
# AI MOVE
# -----------------------------------------------------
func ai_move() -> void:
	await get_tree().create_timer(0.5).timeout

	var move = get_best_ai_move()
	if move.is_empty():
		return

	# use plain = so GDScript doesn’t complain about types
	var r = move[0]
	var c = move[1]

	board[r][c] = ai_symbol

	var btn := grid.get_child(r * 3 + c)
	btn.texture_normal = tex_o
	btn.disabled = true

	if not check_winner():
		player_turn = true
		update_turn_label()


# -----------------------------------------------------
# AI LOGIC (heuristic + random)
# -----------------------------------------------------
func get_best_ai_move() -> Array:
	var empty: Array = []
	for r in range(3):
		for c in range(3):
			if board[r][c] == "":
				empty.append([r, c])

	if empty.is_empty():
		return []

	var smart_chance := ai_difficulty / 10.0

	# SMART MOVE
	if randf() < smart_chance:
		# Try to WIN
		for move in empty:
			board[move[0]][move[1]] = ai_symbol
			if check_temp_winner(ai_symbol):
				board[move[0]][move[1]] = ""
				return move
			board[move[0]][move[1]] = ""

		# BLOCK player
		for move in empty:
			board[move[0]][move[1]] = player_symbol
			if check_temp_winner(player_symbol):
				board[move[0]][move[1]] = ""
				return move
			board[move[0]][move[1]] = ""

		# Center
		if board[1][1] == "":
			return [1, 1]

		# Corners
		var corners := [[0,0],[0,2],[2,0],[2,2]]
		var free_corners: Array = []
		for c in corners:
			if board[c[0]][c[1]] == "":
				free_corners.append(c)
		if free_corners.size() > 0:
			return free_corners[randi() % free_corners.size()]

	# RANDOM fallback
	return empty[randi() % empty.size()]


# TEMP check for hypothetical AI moves
func check_temp_winner(symbol: String) -> bool:
	for i in range(3):
		if board[i][0] == symbol and board[i][1] == symbol and board[i][2] == symbol:
			return true
		if board[0][i] == symbol and board[1][i] == symbol and board[2][i] == symbol:
			return true

	if board[0][0] == symbol and board[1][1] == symbol and board[2][2] == symbol:
		return true
	if board[0][2] == symbol and board[1][1] == symbol and board[2][0] == symbol:
		return true

	return false


# -----------------------------------------------------
# LABELS
# -----------------------------------------------------
func update_turn_label() -> void:
	if not game_over:
		turn_label.text = "Your Turn" if player_turn else "Bot's Turn"


func update_round_label() -> void:
	round_label.text = "Round %d/%d" % [round_count + 1, max_rounds]


# -----------------------------------------------------
# CHECK WINNER / DRAW
# -----------------------------------------------------
func check_winner() -> bool:
	# Rows & columns
	for i in range(3):
		if board[i][0] != "" and board[i][0] == board[i][1] and board[i][1] == board[i][2]:
			end_round(board[i][0]); return true
		if board[0][i] != "" and board[0][i] == board[1][i] and board[1][i] == board[2][i]:
			end_round(board[0][i]); return true

	# Diagonals
	if board[0][0] != "" and board[0][0] == board[1][1] and board[1][1] == board[2][2]:
		end_round(board[0][0]); return true
	if board[0][2] != "" and board[0][2] == board[1][1] and board[1][1] == board[2][0]:
		end_round(board[0][2]); return true

	# Draw?
	for r in range(3):
		for c in range(3):
			if board[r][c] == "":
				return false

	end_round("Draw")
	return true


# -----------------------------------------------------
# END ROUND (LOCAL ONLY, NO GLOBALS)
# -----------------------------------------------------
func end_round(winner: String) -> void:
	game_over = true

	for i in range(9):
		grid.get_child(i).disabled = true

	if winner == "Draw":
		turn_label.text = "Draw!"
	elif winner == player_symbol:
		turn_label.text = "You Won!"
	else:
		turn_label.text = "Bot Won!"

	round_count += 1
	update_round_label()

	await get_tree().create_timer(1.2).timeout

	# loop forever; or remove this block if you want the game to stop
	if round_count >= max_rounds:
		round_count = 0

	reset_board()
