class_name JumpAnimations
extends BaseAnimations


signal jumped
signal vertical_movement_ended

var about_to_land: bool = false

var _can_set_falling: bool = true
var _fade_vertical_movement: bool = false
var _fade_to_fall: bool = false

var _can_emit_vertical_movement_ended: bool = false


func _physics_process(_delta):
	if debug:
		pass
	
	# This blends between the normal movement stuff
	# and all this vertical movement stuff (jump and fall)
	if _fade_vertical_movement:
		anim_tree["parameters/Vertical Movement/blend_amount"] = lerp(
			float(anim_tree["parameters/Vertical Movement/blend_amount"]),
			1.0,
			0.05
		)
		
		# assume we're transitioning to the vertical movement state,
		# allow the ability to emit the signal when we come back down
		if float(anim_tree["parameters/Vertical Movement/blend_amount"]) > 0.8:
			_can_emit_vertical_movement_ended = true
	else:
		anim_tree["parameters/Vertical Movement/blend_amount"] = lerp(
			float(anim_tree["parameters/Vertical Movement/blend_amount"]),
			0.0,
			0.05
		)
	
	# here we assume we've successfully transitioned from the
	# vertical movement state to the normal state
	if _can_emit_vertical_movement_ended and \
		float(anim_tree["parameters/Vertical Movement/blend_amount"]) < 0.8:
		
		_can_emit_vertical_movement_ended = false
		vertical_movement_ended.emit()
	
	# This blends between the jump animation and the
	# falling idle animation
	if _fade_to_fall:
		anim_tree["parameters/Jump and Fall Blend/blend_amount"] = lerp(
			float(anim_tree["parameters/Jump and Fall Blend/blend_amount"]),
			1.0,
			0.05
		)
	else:
		anim_tree["parameters/Jump and Fall Blend/blend_amount"] = lerp(
			float(anim_tree["parameters/Jump and Fall Blend/blend_amount"]),
			0.0,
			0.1
		)


## Method to start the jump animation
func start_jump() -> void:
	anim_tree["parameters/Jump Trim/seek_request"] = 0.65
	anim_tree["parameters/Jump Speed/scale"] = 1.0	
	_fade_vertical_movement = true
	

## When to actually apply the jump force
func jump_force() -> void:
	jumped.emit()
	_can_set_falling = true


## The point in the jump animation where we can
## switch to the falling idle animation
func falling_idle() -> void:
	if _can_set_falling and not about_to_land:
		_can_set_falling = false
		_fade_to_fall = true


## Method to just play the fall animation
## without the jump. Useful if the player
## literally just walks off a platform
func just_fall() -> void:
	anim_tree["parameters/Jump Speed/scale"] = 0.0
	anim_tree["parameters/Jump and Fall Blend/blend_amount"] = 1.0
	_fade_vertical_movement = true
	

## A method to signfiy when to blend from the
## falling idle animation to the rest of the
## jump animation to 'land'
func jump_landing() -> void:
	_fade_to_fall = false


## A method call to transition from jumping
func fade_out() -> void:
	_fade_vertical_movement = false	
	_fade_to_fall = false
