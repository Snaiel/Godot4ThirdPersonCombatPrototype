class_name NonMeleeAction
extends BaseAnimations


@export_category("Secondary Movement Settings")
@export var secondary_movement: bool = true
@export var move_speed: float = 6
@export var time: float = 5
@export var friction: float = 15
@export var direction: Vector3 = Vector3.ZERO


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
