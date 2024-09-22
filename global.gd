extends Node

enum Action {IDLE, WALK, RUN, FALL, PRAY, JUMP, ATTACK}
var CurrentAction : Action = Action.IDLE


func _process(_delta):
	# Handle Quitting
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	# Toggle Fullscreen
	if Input.is_action_just_pressed("toggle_fullscreen"): 
		match DisplayServer.window_get_mode():
			DisplayServer.WINDOW_MODE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.WINDOW_MODE_WINDOWED:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
