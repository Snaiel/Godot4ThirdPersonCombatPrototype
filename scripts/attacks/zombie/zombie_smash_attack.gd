class_name ZombieSmashAttackStrategy
extends AttackStrategy


func _ready():
	attack_name = "zombie_smash"


func play_attack():
	if _play_copy:
		anim_tree["parameters/Zombie Smash Copy/Zombie Smash Trim/seek_request"] = 0.3
		anim_tree["parameters/Attack/transition_request"] = "zombie_smash_copy"
		_play_copy = false
	else:
		anim_tree["parameters/Zombie Smash/Zombie Smash Trim/seek_request"] = 0.3
		anim_tree["parameters/Attack/transition_request"] = "zombie_smash"
		_play_copy = true


func receive_movement():
	print('MOVEMENT')
	movement_component.set_secondary_movement(6, 7, 15)
