class_name SetRootMotion
extends ActionLeaf


@export var root_motion: bool = false


func tick(actor: Node, _blackboard: Blackboard) -> int:
	var entity: Enemy = actor 
	entity.locomotion_component.set_active_strategy(
		"root_motion" if root_motion else "programmatic"
	)
	return SUCCESS
