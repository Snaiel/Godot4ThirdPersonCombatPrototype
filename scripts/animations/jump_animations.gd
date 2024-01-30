class_name JumpAnimations
extends BaseAnimations


signal jumped
signal vertical_movement_ended

var about_to_land: bool = false

var _fade_vertical_movement: bool = false

var _can_set_falling: bool = true
var _fade_to_fall: bool = false

var _do_jump_1: bool = true
var _can_switch_jump: bool = false

var _can_emit_vertical_movement_ended: bool = false

var _just_fall_timer: Timer
var _just_fall_timer_pause: float = 0.1


func _ready():
	_just_fall_timer = Timer.new()
	_just_fall_timer.autostart = false
	_just_fall_timer.one_shot = true
	_just_fall_timer.wait_time = _just_fall_timer_pause
	_just_fall_timer.timeout.connect(
		func():
			_fade_vertical_movement = true
	)
	add_child(_just_fall_timer)


func _physics_process(_delta):
	
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
	
	# this blends between two jump which are exactly the same.
	# this is done because blending/transitioning to the same
	# state is not smooth. so i am blending between two of the
	# same jump animation so that it looks like jumping
	# straight away after jumping is smooth.
	if _do_jump_1 and _can_switch_jump:
		anim_tree["parameters/Jump Handler/blend_amount"] = lerp(
			float(anim_tree["parameters/Jump Handler/blend_amount"]),
			0.0,
			0.1
		)
		if anim_tree["parameters/Jump Handler/blend_amount"] < 0.02:
			_do_jump_1 = false
			_can_switch_jump = false
	if not _do_jump_1 and _can_switch_jump:
		anim_tree["parameters/Jump Handler/blend_amount"] = lerp(
			float(anim_tree["parameters/Jump Handler/blend_amount"]),
			1.0,
			0.1
		)
		if anim_tree["parameters/Jump Handler/blend_amount"] > 0.98:
			_do_jump_1 = true
			_can_switch_jump = false
	
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
	
	# here we assume we've successfully transitioned from the
	# vertical movement state to the normal state
	if _can_emit_vertical_movement_ended and \
		float(anim_tree["parameters/Vertical Movement/blend_amount"]) < 0.8:
		
		_can_emit_vertical_movement_ended = false
		vertical_movement_ended.emit()


## Method to start the jump animation
func start_jump() -> void:
	
	if _do_jump_1:
		anim_tree["parameters/Jump 1/Jump Trim/seek_request"] = 0.65
		anim_tree["parameters/Jump 1/Jump Speed/scale"] = 1.0
	else:
		anim_tree["parameters/Jump 2/Jump Trim/seek_request"] = 0.65
		anim_tree["parameters/Jump 2/Jump Speed/scale"] = 1.0
	
	_can_switch_jump = true
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
	if _just_fall_timer.is_stopped():
		_just_fall_timer.start()
	
	_fade_to_fall = true
	
	if float(anim_tree["parameters/Vertical Movement/blend_amount"]) < 0.05:
		anim_tree["parameters/Jump and Fall Blend/blend_amount"] = 1.0
	
	anim_tree["parameters/Jump 1/Jump Speed/scale"] = 0.0
	anim_tree["parameters/Jump 1/Jump Speed/scale"] = 0.0


## A method to signfiy when to blend from the
## falling idle animation to the rest of the
## jump animation to 'land'
func jump_landing() -> void:
	_fade_to_fall = false


## A method call to transition from jumping
func fade_out() -> void:
	_fade_vertical_movement = false	
	_fade_to_fall = false
