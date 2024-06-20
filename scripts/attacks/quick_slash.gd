class_name QuickSlashAttackStrategy
extends AttackStrategy


func _ready():
	attack_name = "quick_slash"


func play_attack():
	anim_tree["parameters/Attack Quick Slash/Quick Slash Trim/seek_request"] = 0.9
	anim_tree["parameters/Attack Quick Slash/Walk Forwards Trim/seek_request"] = 0.8
	anim_tree["parameters/Attack Quick Slash/Walk Forwards Speed/scale"] = 0.8				
	anim_tree["parameters/Attack/transition_request"] = "quick_slash"


func receive_movement():
	movement_component.set_secondary_movement(6, 5, 15)


func play_legs():
	anim_tree["parameters/Attack Quick Slash/Walk Forwards Speed/scale"] = 0.8


func perform_legs_transition():
	pass


func end_legs_transition():
	anim_tree["parameters/Attack Quick Slash/Walk Forwards Speed/scale"] = lerp(
		float(anim_tree["parameters/Attack Quick Slash/Walk Forwards Speed/scale"]),
		0.05,
		0.3
	)
