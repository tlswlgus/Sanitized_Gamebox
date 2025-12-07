extends Node

# -------------------------------------
# BASIC GAME STATE (SANITIZED)
# -------------------------------------

var current_game_index: int = -1
var current_score: int = 0
var round: int = 0
var paused: bool = false

var previous_game: String = ""
var previous_games: Array = []   # Sliding window for non-repeat selection

var single_player: bool = true
var next_game_path: String = ""

# -------------------------------------
# GAME LISTS (GENERIC – NO INTERNAL LOGIC LEAKED)
# -------------------------------------
var single_gamelist := {
	5: "res://Scenes/Dodge/Dodge_Single.tscn",
	4: "res://Scenes/Dasher/Dasher_Single.tscn",
	3: "res://Scenes/TicTacToe/TicTacToe_Single.tscn",
	2: "res://Scenes/Catch/Catch_Single.tscn",
	1: "res://Scenes/Pong/Pong_Single.tscn"
}

# -------------------------------------
# RANDOM NON-REPEATING GAME SELECTION
# (Rejection Sampling + Sliding Window)
# -------------------------------------
func load_single_game() -> void:
	var keys: Array = single_gamelist.keys()
	var new_game = null

	# reject repeats (sliding window constraint)
	while new_game == null or new_game in previous_games:
		new_game = keys[randi() % keys.size()]

	# maintain window size (last 2 games)
	previous_games.append(new_game)
	if previous_games.size() > 2:
		previous_games.pop_front()
	get_tree().change_scene_to_file(single_gamelist[new_game])
