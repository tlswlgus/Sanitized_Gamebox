extends Node2D

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
		
	$Game_Round.text = "Round: " + str(GlobalState.round) + "\nDasher"
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
