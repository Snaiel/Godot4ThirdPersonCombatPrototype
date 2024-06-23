class_name OutwardAttackStrategy
extends AttackStrategy


func _ready():
	attack_name = "outward_slash"


func play_attack():
	if _play_copy:
		anim_tree["parameters/Attack Outward Slash Copy/Outward Slash Trim/seek_request"] = 0.5
		anim_tree["parameters/Attack Outward Slash Copy/Walk Forwards Trim/seek_request"] = 0.955
		anim_tree["parameters/Attack Outward Slash Copy/Walk Forwards Speed/scale"] = 0.0
		anim_tree["parameters/Attack/transition_request"] = "outward_slash_copy"
		_play_copy = false
	else:
		anim_tree["parameters/Attack Outward Slash/Outward Slash Trim/seek_request"] = 0.5
		anim_tree["parameters/Attack Outward Slash/Walk Forwards Trim/seek_request"] = 0.955
		anim_tree["parameters/Attack Outward Slash/Walk Forwards Speed/scale"] = 0.0
		anim_tree["parameters/Attack/transition_request"] = "outward_slash"
		_play_copy = true


func play_legs() -> void:
	anim_tree["parameters/Attack Outward Slash/Walk Forwards Speed/scale"] = 0.8
	anim_tree["parameters/Attack Outward Slash Copy/Walk Forwards Speed/scale"] = 0.8


func perform_legs_transition():
	pass


func end_legs_transition():
	anim_tree["parameters/Attack Outward Slash/Walk Forwards Speed/scale"] = lerp(
		float(anim_tree["parameters/Attack Outward Slash/Walk Forwards Speed/scale"]),
		0.05,
		0.3
	)
	anim_tree["parameters/Attack Outward Slash Copy/Walk Forwards Speed/scale"] = lerp(
		float(anim_tree["parameters/Attack Outward Slash Copy/Walk Forwards Speed/scale"]),
		0.05,
		0.3
	)
