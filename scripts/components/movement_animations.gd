class_name MovementAnimations
extends Node3D

signal can_rotate(flag: bool)

var _lock_on_walk_blend = 0.0
var _input_dir = Vector2.ZERO

func move(dir: Vector3, locked_on: bool, running: bool):
	var new_dir = Vector2(dir.x, dir.z)
	
	_input_dir = _input_dir.lerp(new_dir, 0.1)

	if dir.length() > 0.2:
		_lock_on_walk_blend = lerp(_lock_on_walk_blend, 1.0, 0.05)
		anim_tree["parameters/Lock On Walk/blend_position"] = _input_dir
	else:
		_lock_on_walk_blend = lerp(_lock_on_walk_blend, 0.0, 0.1)
		
	anim_tree["parameters/Lock On Movement/blend_amount"] = _lock_on_walk_blend
	anim_tree["parameters/Free Movement/blend_amount"] = _lock_on_walk_blend	
	
	if locked_on:
		anim_tree["parameters/Walking Lock On/transition_request"] = "locked_on"
		anim_tree["parameters/Running Lock On/transition_request"] = "locked_on"		
	else:
		anim_tree["parameters/Walking Lock On/transition_request"] = "not_locked_on"		
		anim_tree["parameters/Running Lock On/transition_request"] = "not_locked_on"
		
	if running and _input_dir.length() > 0.5:
		anim_tree["parameters/Movement/blend_amount"] = lerp(anim_tree["parameters/Movement/blend_amount"], 1.0, 0.1)
	else:
		anim_tree["parameters/Movement/blend_amount"] = lerp(anim_tree["parameters/Movement/blend_amount"], 0.0, 0.1)		
		
	anim_tree["parameters/Running Lock On Look Direction/blend_position"] = _input_dir
