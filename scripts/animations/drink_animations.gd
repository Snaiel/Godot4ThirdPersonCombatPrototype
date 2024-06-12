class_name DrinkAnimations
extends BaseAnimations


signal gain_health
signal finished
signal interupted


var _blend_drinking: bool = false
var _interupted: bool = false

func _physics_process(_delta):
	if _blend_drinking:
		anim_tree["parameters/Drinking/blend_amount"] = lerp(
			float(anim_tree["parameters/Drinking/blend_amount"]),
			1.0,
			0.05
		)
	else:
		anim_tree["parameters/Drinking/blend_amount"] = lerp(
			float(anim_tree["parameters/Drinking/blend_amount"]),
			0.0,
			0.05
		)


func drink() -> void:
	parent_animations.walk_or_jog_animations.set_walk_speed(0.5)
	parent_animations.walk_or_jog_animations.to_walking()
	parent_animations.walk_or_jog_animations.can_change_state = false
	parent_animations.walk_or_jog_animations.can_change_speed = false
	_blend_drinking = true
	_interupted = false
	anim_tree["parameters/Drinking Trim/seek_request"] = 1.5
	anim_tree["parameters/Drinking Speed/scale"] = 1.5

func interupt_drink() -> void:
	parent_animations.walk_or_jog_animations.reset_walk_speed()
	parent_animations.walk_or_jog_animations.to_jogging()
	_blend_drinking = false
	_interupted = true
	interupted.emit()

func receive_gain_health() -> void:
	if _interupted:
		return
	
	parent_animations.walk_or_jog_animations.can_change_state = true
	parent_animations.walk_or_jog_animations.can_change_speed = true
	gain_health.emit()

func receive_finished() -> void:
	if _interupted:
		return
	
	parent_animations.walk_or_jog_animations.reset_walk_speed()
	parent_animations.walk_or_jog_animations.to_jogging()
	_blend_drinking = false
	finished.emit()
