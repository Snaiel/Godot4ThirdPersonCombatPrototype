extends Node3D


@export var character: CharacterAnimations
@export var blackboard: Blackboard
@export var instability_component: InstabilityComponent


func _ready():
	instability_component.full_instability.connect(
		func(flag: bool):
			blackboard.set_value("dizzy", flag)
			blackboard.set_value("interrupt_timers", true)
			character.dizzy_animations.dizzy_from_parry(flag)
	)
