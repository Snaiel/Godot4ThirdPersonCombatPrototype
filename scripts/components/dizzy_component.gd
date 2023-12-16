extends Node3D


@export var character: CharacterAnimations
@export var blackboard: Blackboard
@export var instability_component: InstabilityComponent


func _ready():
	instability_component.full_instability.connect(
		func():
			blackboard.set_value("dizzy", true)
			blackboard.set_value("interrupt_timers", true)
			character.dizzy_animations.dizzy_from_parry()
	)
