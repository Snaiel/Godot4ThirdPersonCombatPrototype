class_name ZombieKickAttackStrategy
extends AttackStrategy


func _ready():
	attack_name = "zombie_kick"


func play_attack():
	if _play_copy:
		anim_tree["parameters/Zombie Kick Copy/Zombie Kick Trim/seek_request"] = 0.2
		anim_tree["parameters/Attack/transition_request"] = "zombie_kick_copy"
		_play_copy = false
	else:
		anim_tree["parameters/Zombie Kick/Zombie Kick Trim/seek_request"] = 0.2
		anim_tree["parameters/Attack/transition_request"] = "zombie_kick"
		_play_copy = true


func receive_movement():
	print('MOVEMENT')
	movement_component.set_secondary_movement(6, 7, 15)
