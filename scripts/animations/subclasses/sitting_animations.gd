class_name SittingAnimations
extends BaseAnimations


signal sat_down
signal finished


var sitting_idle: bool

var _active: bool = false
var _transitioning: bool = false
var _ignore_method_calls: bool = false
var _previous_sitting_blend: float = 0.0

var _can_emit_sat_down: bool = false


func _ready():
	pass # Replace with function body.


func _physics_process(_delta):
	if _active:
		anim_tree["parameters/Sitting/blend_amount"] = lerp(
			float(anim_tree["parameters/Sitting/blend_amount"]),
			1.0,
			0.02
		)
	else:
		anim_tree["parameters/Sitting/blend_amount"] = move_toward(
			float(anim_tree["parameters/Sitting/blend_amount"]),
			0.0,
			0.02
		)
	
	if _transitioning:
		anim_tree["parameters/Sitting or Standing/blend_amount"] = lerp(
			float(anim_tree["parameters/Sitting or Standing/blend_amount"]),
			1.0,
			0.02
		)
	else:
		anim_tree["parameters/Sitting or Standing/blend_amount"] = lerp(
			float(anim_tree["parameters/Sitting or Standing/blend_amount"]),
			0.0,
			0.02
		)
	
	if float(anim_tree["parameters/Sitting or Standing/blend_amount"]) < 0.1 and \
	_active:
		sitting_idle = true
		if _can_emit_sat_down:
			_can_emit_sat_down = false
			sat_down.emit()
	else:
		sitting_idle = false
	
	if float(anim_tree["parameters/Sitting/blend_amount"]) < 0.05 and \
	_previous_sitting_blend >= 0.05:
		finished.emit()
	
	_previous_sitting_blend = float(anim_tree["parameters/Sitting/blend_amount"])


func sit_down() -> void:
	_ignore_method_calls = true
	_can_emit_sat_down = true
	
	anim_tree["parameters/Sitting or Standing/blend_amount"] = 1.0
	anim_tree["parameters/Sit to Stand Speed/scale"] = -1.5
	anim_tree["parameters/Sit to Stand Trim/seek_request"] = 5.0
	
	_active = true
	_transitioning = true
	
	var timer: SceneTreeTimer = get_tree().create_timer(1.5)
	timer.timeout.connect(
		func():
			_ignore_method_calls = false
	)


func blend_to_idle() -> void:
	if _ignore_method_calls:
		return
	
	_active = true
	_transitioning = false


func stand_up() -> void:
	_ignore_method_calls = true
	
	anim_tree["parameters/Sitting or Standing/blend_amount"] = 0.0
	anim_tree["parameters/Sit to Stand Speed/scale"] = 2
	anim_tree["parameters/Sit to Stand Trim/seek_request"] = 0.0
	
	_active = true
	_transitioning = true
	
	var timer: SceneTreeTimer = get_tree().create_timer(2.0)
	timer.timeout.connect(
		func():
			_ignore_method_calls = false
	)


func finish_standing_up() -> void:
	if _ignore_method_calls:
		return
	
	_active = false
