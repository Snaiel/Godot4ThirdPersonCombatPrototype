extends ConditionLeaf

@export var min_angle: float = 1.2

func tick(_actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("target_dir_angle", min_angle) < min_angle:
		return SUCCESS
	return FAILURE
