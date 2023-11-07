class_name CloseToTarget
extends ConditionLeaf

@export var range: float

func tick(_actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("target_dist", range) < range:
		return SUCCESS
	return FAILURE
