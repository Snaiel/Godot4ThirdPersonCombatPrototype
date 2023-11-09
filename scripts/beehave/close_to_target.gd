class_name CloseToTarget
extends ConditionLeaf

@export var target_range: float

func tick(_actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("target_dist", target_range) < target_range:
		return SUCCESS
	return FAILURE
