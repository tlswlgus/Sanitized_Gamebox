extends Control


func _on_start_single_button_pressed() -> void:
	GlobalState.previous_games = [] 
	GlobalState.single_player = true
	GlobalState.load_single_game()
	
