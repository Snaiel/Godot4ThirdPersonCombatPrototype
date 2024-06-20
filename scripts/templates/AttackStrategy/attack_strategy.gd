# meta-name: Attack Strategy
# meta-default: true
# meta-space-indent: 4

class_name NewAttackStrategy
extends AttackStrategy


func _ready():
	attack_name = ""


func play_attack() -> void:
	pass


func receive_movement() -> void:
	pass


func play_legs() -> void:
	pass


func perform_legs_transition() -> void:
	pass


func end_legs_transition() -> void:
	pass
