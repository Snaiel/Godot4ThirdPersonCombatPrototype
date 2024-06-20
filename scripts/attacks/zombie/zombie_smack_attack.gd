class_name ZombieSmackAttackStrategy
extends AttackStrategy


func _ready():
	attack_name = "zombie_punch"


func play_attack():
	if _play_copy:
		anim_tree["parameters/Zombie Smack Copy/Zombie Smack Trim/seek_request"] = 0.3
		anim_tree["parameters/Attack/transition_request"] = "zombie_smack_copy"
		_play_copy = false
	else:
		anim_tree["parameters/Zombie Smack/Zombie Smack Trim/seek_request"] = 0.3
		anim_tree["parameters/Attack/transition_request"] = "zombie_smack"
		_play_copy = true


func receive_movement():
	print('MOVEMENT')
	movement_component.set_secondary_movement(6, 7, 15)
