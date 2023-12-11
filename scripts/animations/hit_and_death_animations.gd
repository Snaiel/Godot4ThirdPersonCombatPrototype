class_name HitAndDeathAnimations
extends BaseAnimations


var _death: bool = false
var _blend_death: bool = false

var _hit_timer: Timer
var _hit_wait_time: float = 0.3


func _ready():
	_hit_timer = Timer.new()
	_hit_timer.wait_time = _hit_wait_time
	_hit_timer.one_shot = true
	_hit_timer.autostart = false
	_hit_timer.timeout.connect(
		func():
			_blend_death = false
	)
	add_child(_hit_timer)


func _physics_process(_delta) -> void:
	if _death:
		_blend_death = true
		
	if _blend_death:
		anim_tree["parameters/Death/blend_amount"] = lerp(
			float(anim_tree["parameters/Death/blend_amount"]),
			1.0,
			0.2
		)
	else:
		anim_tree["parameters/Death/blend_amount"] = lerp(
			float(anim_tree["parameters/Death/blend_amount"]),
			0.0,
			0.05
		)


func hit() -> void:
	if _death:
		return
		
	anim_tree["parameters/Death 2 Trim/seek_request"] = 0.4
	anim_tree["parameters/Death Which One/transition_request"] = "death_2"
	_blend_death = true
	_hit_timer.start()


func death_1() -> void:
	anim_tree["parameters/Death Which One/transition_request"] = "death_1"
	anim_tree["parameters/Death 1 Trim/seek_request"] = 0.1
	_death = true


func death_2() -> void:
	anim_tree["parameters/Death Which One/transition_request"] = "death_2"
	anim_tree["parameters/Death 2 Trim/seek_request"] = 0.0
	_death = true
