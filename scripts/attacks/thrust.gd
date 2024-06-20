class_name ThrustAttackStrategy
extends AttackStrategy


func _ready():
	attack_name = "thrust"


func play_attack():
	anim_tree["parameters/Attack/transition_request"] = "thrust"


func receive_movement():
	movement_component.set_secondary_movement(6, 5, 15)


func play_legs() -> void:
	pass

func perform_legs_transition():
	pass


func end_legs_transition():
	pass

