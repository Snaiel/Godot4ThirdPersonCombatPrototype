class_name SetRootMotion
extends ActionLeaf


@export var entity: Enemy
@export var root_motion: bool = false


func tick(_actor: Node, _blackboard: Blackboard) -> int:
	entity.locomotion_component.set_active_strategy(
		"root_motion" if root_motion else "programmatic"
	)
	return SUCCESS
