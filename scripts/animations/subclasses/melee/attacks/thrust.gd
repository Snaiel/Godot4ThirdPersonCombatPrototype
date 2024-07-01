class_name ThrustMeleeAttack
extends MeleeAttack


func _ready():
	attack_name = "thrust"


func play_attack():
	anim_tree.set(&"parameters/Attack/transition_request", &"thrust")


func play_legs() -> void:
	pass


func perform_legs_transition():
	pass


func end_legs_transition():
	pass

