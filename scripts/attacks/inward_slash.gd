class_name InwardAttackStrategy
extends AttackStrategy


func _ready():
	attack_name = "inward_slash"


func play_attack():
	if _play_copy:
		anim_tree["parameters/Attack Inward Slash Copy/Inward Slash and Walk Blend/blend_amount"] = 0.0
		anim_tree["parameters/Attack Inward Slash Copy/Inward Slash Trim/seek_request"] = 0.0
		anim_tree["parameters/Attack Inward Slash Copy/Walk Forwards Trim/seek_request"] = 0.55
		anim_tree["parameters/Attack Inward Slash Copy/Walk Forwards Speed/scale"] = 0.0
		anim_tree["parameters/Attack/transition_request"] = "inward_slash_copy"
		_play_copy = false
	else:
		anim_tree["parameters/Attack Inward Slash/Inward Slash and Walk Blend/blend_amount"] = 0.0
		anim_tree["parameters/Attack Inward Slash/Inward Slash Trim/seek_request"] = 0.0
		anim_tree["parameters/Attack Inward Slash/Walk Forwards Trim/seek_request"] = 0.55
		anim_tree["parameters/Attack Inward Slash/Walk Forwards Speed/scale"] = 0.0
		anim_tree["parameters/Attack/transition_request"] = "inward_slash"
		_play_copy = true


func receive_movement():
	movement_component.set_secondary_movement(6, 5, 15)


func play_legs() -> void:
	anim_tree["parameters/Attack Inward Slash/Walk Forwards Speed/scale"] = 0.8
	anim_tree["parameters/Attack Inward Slash Copy/Walk Forwards Speed/scale"] = 0.8


func perform_legs_transition():
	anim_tree["parameters/Attack Inward Slash/Inward Slash and Walk Blend/blend_amount"] = lerp(
		float(anim_tree["parameters/Attack Inward Slash/Inward Slash and Walk Blend/blend_amount"]), 
		1.0, 
		0.3
	)
	anim_tree["parameters/Attack Inward Slash Copy/Inward Slash and Walk Blend/blend_amount"] = lerp(
		float(anim_tree["parameters/Attack Inward Slash Copy/Inward Slash and Walk Blend/blend_amount"]), 
		1.0, 
		0.3
	)

func end_legs_transition():
	anim_tree["parameters/Attack Inward Slash/Walk Forwards Speed/scale"] = lerp(
		float(anim_tree["parameters/Attack Inward Slash/Walk Forwards Speed/scale"]), 
		0.05, 
		0.3
	)
	anim_tree["parameters/Attack Inward Slash Copy/Walk Forwards Speed/scale"] = lerp(
		float(anim_tree["parameters/Attack Inward Slash Copy/Walk Forwards Speed/scale"]), 
		0.05, 
		0.3
	)

