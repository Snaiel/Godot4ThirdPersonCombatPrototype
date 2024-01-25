class_name AudioFootsteps
extends AudioStreamPlayer3D


var can_play: bool = true
var on_floor: bool = true
var running: bool = false


func play_footstep() -> void:
	if not can_play:
		return
	
	if not on_floor:
		return
	
	if playing:
		return
	
	if running:
		pitch_scale = 0.7
	else:
		pitch_scale = 0.8
	
	play()
