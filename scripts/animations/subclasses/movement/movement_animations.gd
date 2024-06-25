class_name MovementAnimations
extends BaseAnimations


@export var audio_footsteps: AudioFootsteps

var movement_animations: Array[BaseMovementAnimations]

var _input_dir: Vector2 = Vector2.ZERO


func _ready():
	for child in get_children():
		movement_animations.append(child)


func move(dir: Vector3, locked_on: bool, running: bool) -> void:
	var new_dir = Vector2(dir.x, dir.z)
	_input_dir = _input_dir.lerp(new_dir, 0.3)
	
	for anim in movement_animations:
		anim.move(_input_dir, locked_on, running)
	
	if _input_dir.length() > 0.01:
		audio_footsteps.can_play = true
	else:
		audio_footsteps.can_play = false
