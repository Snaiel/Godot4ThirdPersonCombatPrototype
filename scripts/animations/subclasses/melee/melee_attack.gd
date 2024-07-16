class_name MeleeAttack
extends BaseAnimations


@export var damage_attributes: DamageAttributes = \
	preload("res://resources/DefaultDamageAttributes.tres")
@export var secondary_movement: SecondaryMovement = \
	preload("res://resources/DefaultMeleeAttackSecondaryMovement.tres")

var attack_name: StringName

# A flag that signifies whether to play
# the attack 1 animation or the copy
# of the attack 1 animation. This is done
# to rectify the issue of instant
# transitions when the transition node
# in the blend tree is requested to play
# the animation that is currently playing.
var _play_copy: bool = false


func play_attack() -> void:
	if _play_copy:
		pass
	else:
		pass


func play_legs() -> void:
	pass


func perform_legs_transition() -> void:
	pass


func end_legs_transition() -> void:
	pass
