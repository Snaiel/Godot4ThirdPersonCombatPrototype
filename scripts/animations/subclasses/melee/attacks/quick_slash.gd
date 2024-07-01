class_name QuickSlashMeleeAttack
extends MeleeAttack


func _ready():
	attack_name = "quick_slash"


func play_attack():
	anim_tree.set(&"parameters/Attack Quick Slash/Quick Slash Trim/seek_request", 0.9)
	anim_tree.set(&"parameters/Attack Quick Slash/Walk Forwards Trim/seek_request", 0.8)
	anim_tree.set(&"parameters/Attack Quick Slash/Walk Forwards Speed/scale", 0.8)
	anim_tree.set(&"parameters/Attack/transition_request", &"quick_slash")


func play_legs():
	anim_tree.set(&"parameters/Attack Quick Slash/Walk Forwards Speed/scale", 0.8)


func perform_legs_transition():
	pass


func end_legs_transition():
	var speed = anim_tree.get(&"parameters/Attack Quick Slash/Walk Forwards Speed/scale")
	if speed == null: return
	anim_tree.set(
		&"parameters/Attack Quick Slash/Walk Forwards Speed/scale",
		lerp(
			float(speed),
			0.05,
			0.3
		)
	)
