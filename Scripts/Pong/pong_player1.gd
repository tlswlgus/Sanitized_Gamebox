extends CharacterBody2D

func _unhandled_input(event):
	if event is InputEventScreenDrag or event is InputEventScreenTouch:
		if event.position.y > get_viewport().size.y / 2:
			global_position.x = event.position.x
