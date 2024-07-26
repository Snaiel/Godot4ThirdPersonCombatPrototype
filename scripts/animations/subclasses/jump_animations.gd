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

var _vertical_blend: float = 0.0
var _fall_blend: float = 0.0


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
	
	anim_tree.set(&"parameters/Jump Handler/transition_request", &"jump_1")


func _physics_process(_delta):
	
	if not BaseAnimations.should_return_blend(
		_fade_vertical_movement, _vertical_blend
	):
		# This blends between the normal movement stuff
		# and all this vertical movement stuff (jump and fall)
		var vertical_blend = anim_tree.get(
			&"parameters/Vertical Movement/blend_amount"
		)
		if vertical_blend == null: return
		
		_vertical_blend = lerp(
			float(vertical_blend),
			1.0 if _fade_vertical_movement else 0.0,
			0.05
		)
		
		anim_tree.set(
			&"parameters/Vertical Movement/blend_amount",
			_vertical_blend
		)
	
	# assume we're transitioning to the vertical movement state,
	# allow the ability to emit the signal when we come back down
	if _vertical_blend > 0.8:
		_can_emit_vertical_movement_ended = true
	
	
	if not BaseAnimations.should_return_blend(_fade_to_fall, _fall_blend):
		# This blends between the jump animation and the falling idle animation
		var jump_and_fall_blend = anim_tree.get(
			&"parameters/Jump and Fall Blend/blend_amount"
		)
		if jump_and_fall_blend == null: return
		
		_fall_blend = lerp(
			float(jump_and_fall_blend),
			1.0 if _fade_to_fall else 0.0,
			0.05 if _fade_to_fall else 0.1
		)
		
		anim_tree.set(
			&"parameters/Jump and Fall Blend/blend_amount",
			_fall_blend
		)
	
	# here we assume we've successfully transitioned from the
	# vertical movement state to the normal state
	if _can_emit_vertical_movement_ended and _vertical_blend < 0.8:
		_can_emit_vertical_movement_ended = false
		vertical_movement_ended.emit()


## Method to start the jump animation
func start_jump() -> void:
	
	if _do_jump_1:
		anim_tree.set(&"parameters/Jump 1/Jump Trim/seek_request", 0.65)
		anim_tree.set(&"parameters/Jump 1/Jump Speed/scale", 1.0)
		anim_tree.set(&"parameters/Jump Handler/transition_request", &"jump_1")
	else:
		anim_tree.set(&"parameters/Jump 2/Jump Trim/seek_request", 0.65)
		anim_tree.set(&"parameters/Jump 2/Jump Speed/scale", 1.0)
		anim_tree.set(&"parameters/Jump Handler/transition_request", &"jump_2")
	
	_do_jump_1 = not _do_jump_1
	
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
	
	var blend = anim_tree.get(&"parameters/Vertical Movement/blend_amount")
	if blend != null and blend < 0.05:
		anim_tree.set(&"parameters/Jump and Fall Blend/blend_amount", 1.0)
	
	anim_tree.set(&"parameters/Jump 1/Jump Speed/scale", 0.0)
	anim_tree.set(&"parameters/Jump 2/Jump Speed/scale", 0.0)


## A method to signfiy when to blend from the
## falling idle animation to the rest of the
## jump animation to 'land'
func jump_landing() -> void:
	_fade_to_fall = false


## A method call to transition from jumping
func fade_out() -> void:
	_fade_vertical_movement = false	
	_fade_to_fall = false
