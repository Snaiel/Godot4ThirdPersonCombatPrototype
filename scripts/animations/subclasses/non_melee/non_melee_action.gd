class_name NonMeleeAction
extends BaseAnimations


@export var secondary_movement: SecondaryMovement = \
	preload("res://resources/DefaultMeleeAttackSecondaryMovement.tres")


# A flag that signifies whether to play
# the original or copy. This is done
# to rectify the issue of instant
# transitions when the transition node
# in the blend tree is requested to play
# the animation that is currently playing.
var _play_copy: bool = false


func play_animation() -> void:
	if _play_copy:
		pass
	else:
		pass
