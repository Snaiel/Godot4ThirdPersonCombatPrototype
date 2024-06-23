class_name ThrustAttackStrategy
extends AttackStrategy


func _ready():
	attack_name = "thrust"


func play_attack():
	anim_tree["parameters/Attack/transition_request"] = "thrust"


func play_legs() -> void:
	pass


func perform_legs_transition():
	pass


func end_legs_transition():
	pass

