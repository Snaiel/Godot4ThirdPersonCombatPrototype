class_name MovementAnimations
extends BaseAnimations


@export var audio_footsteps: AudioFootsteps

var _input_dir: Vector2 = Vector2.ZERO
var _lock_on_walk_blend: float = 0.0


func _ready() -> void:
	anim_tree["parameters/Free Walk Speed/scale"] = 1


func move(dir: Vector3, locked_on: bool, running: bool) -> void:
	var new_dir = Vector2(dir.x, dir.z)
	_input_dir = _input_dir.lerp(new_dir, 0.3)
	
	
	if locked_on:
		anim_tree["parameters/Walking Lock On/transition_request"] = "locked_on"
		anim_tree["parameters/Running Lock On/transition_request"] = "locked_on"
	else:
		anim_tree["parameters/Walking Lock On/transition_request"] = "not_locked_on"
		anim_tree["parameters/Running Lock On/transition_request"] = "not_locked_on"
	
	
	anim_tree["parameters/Lock On Walk/blend_position"] = _input_dir
	
	if _input_dir.length() > 0.1:
		_lock_on_walk_blend = lerp(_lock_on_walk_blend, 1.0, 0.05)
	else:
		_lock_on_walk_blend = lerp(_lock_on_walk_blend, 0.0, 0.1)
	
	anim_tree["parameters/Lock On Movement/blend_amount"] = _lock_on_walk_blend
	anim_tree["parameters/Free Movement/blend_amount"] = _lock_on_walk_blend
	
	
	anim_tree["parameters/Running Lock On Look Direction/blend_position"] = _input_dir
	
	if running and _input_dir.length() > 0.5:
		anim_tree["parameters/Movement/blend_amount"] = lerp(anim_tree["parameters/Movement/blend_amount"], 1.0, 0.1)
	else:
		anim_tree["parameters/Movement/blend_amount"] = lerp(anim_tree["parameters/Movement/blend_amount"], 0.0, 0.1)
	
	
	if _input_dir.length() > 0.01:
		audio_footsteps.can_play = true
	else:
		audio_footsteps.can_play = false
