class_name JumpAnimations
extends BaseAnimations

signal jumped

var about_to_land: bool = false

var _can_set_falling: bool = true
var _fade_to_fall: bool = false


func _physics_process(_delta):
	if debug:
		pass
#		prints(_fade_to_fall, anim_tree["parameters/Jump and Fall Blend/blend_amount"])
	
	# This blends between the jump animation and the
	# falling idle animation
	if _fade_to_fall:
		anim_tree["parameters/Jump and Fall Blend/blend_amount"] = lerp(
			float(anim_tree["parameters/Jump and Fall Blend/blend_amount"]),
			1.0,
			0.1
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
	anim_tree["parameters/Jump and Fall/transition_request"] = "jump_and_fall"


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
	

## A method to signfiy when to blend from the
## falling idle animation to the rest of the
## jump animation to 'land'
func jump_landing() -> void:
	_fade_to_fall = false


## A method call to transition from jumping
func fade_out() -> void:
	anim_tree["parameters/Jump and Fall/transition_request"] = "none"
	_fade_to_fall = false
