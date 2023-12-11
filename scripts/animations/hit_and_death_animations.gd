class_name HitAndDeathAnimations
extends BaseAnimations


var _blend_death: bool = false


func _ready() -> void:
	pass


func _physics_process(_delta) -> void:
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
			0.2
		)

func death_1() -> void:
	anim_tree["parameters/Death 1 Trim/seek_request"] = 0.0
	anim_tree["parameters/Death Which One/transition_request"] = "death_1"
	_blend_death = true

func death_2() -> void:
	anim_tree["parameters/Death 2 Trim/seek_request"] = 0.0
	anim_tree["parameters/Death Which One/transition_request"] = "death_2"
	_blend_death = true
