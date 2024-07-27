class_name SitAnimations
extends BaseAnimations


signal sat_down
signal finished


var sitting_idle: bool

var _active: bool = false
var _transitioning: bool = false
var _ignore_method_calls: bool = false

var _can_emit_sat_down: bool = false
var _can_emit_finished: bool = false

var _sitting_blend: float = 0.0
var _sit_or_stand_blend: float = 0.0


func _physics_process(_delta):
	if not BaseAnimations.should_return_blend(_active, _sitting_blend):
		var sitting_blend = anim_tree.get(&"parameters/Sit/blend_amount")
		if sitting_blend == null: return
		
		_sitting_blend = lerp(
			float(sitting_blend),
			1.0 if _active else 0.0,
			0.02 if _active else 0.08
		)
		
		anim_tree.set(
			&"parameters/Sit/blend_amount",
			_sitting_blend
		)
	
	if not BaseAnimations.should_return_blend(_transitioning, _sit_or_stand_blend):
		var sit_or_stand_blend = anim_tree.get(&"parameters/Sit or Stand/blend_amount")
		if sit_or_stand_blend == null: return
		
		_sit_or_stand_blend = lerp(
			float(sit_or_stand_blend),
			1.0 if _transitioning else 0.0,
			0.02
		)
		
		anim_tree.set(
			&"parameters/Sit or Stand/blend_amount",
			_sit_or_stand_blend
		)
	
	if float(_sit_or_stand_blend) < 0.1 and _active:
		sitting_idle = true
		if _can_emit_sat_down:
			_can_emit_sat_down = false
			sat_down.emit()
	else:
		sitting_idle = false
	
	if float(_sitting_blend) < 0.1 and _can_emit_finished:
		_can_emit_finished = false
		finished.emit()


func sit_down() -> void:
	_ignore_method_calls = true
	_can_emit_sat_down = true
	
	anim_tree.set(&"parameters/Sit or Stand/blend_amount", 1.0)
	anim_tree.set(&"parameters/Sit to Stand Speed/scale", -1.5)
	anim_tree.set(&"parameters/Sit to Stand Trim/seek_request", 5.0)
	
	_active = true
	_transitioning = true
	
	var timer: SceneTreeTimer = get_tree().create_timer(1.5)
	timer.timeout.connect(
		func():
			_ignore_method_calls = false
	)


func blend_to_idle() -> void:
	if _ignore_method_calls: return
	_active = true
	_transitioning = false


func stand_up() -> void:
	_ignore_method_calls = true
	_can_emit_finished = true
	
	anim_tree.set(&"parameters/Sit or Stand/blend_amount", 0.0)
	anim_tree.set(&"parameters/Sit to Stand Speed/scale", 2)
	anim_tree.set(&"parameters/Sit to Stand Trim/seek_request", 0.0)
	
	_active = true
	_transitioning = true
	
	var timer: SceneTreeTimer = get_tree().create_timer(1.5)
	timer.timeout.connect(
		func():
			_ignore_method_calls = false
	)


func finish_standing_up() -> void:
	if _ignore_method_calls: return
	_active = false
