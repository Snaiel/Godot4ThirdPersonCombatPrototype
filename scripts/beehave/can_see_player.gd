extends ConditionLeaf

@export var min_angle = 1.2

func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("player_dir_angle", min_angle) < min_angle:
		return SUCCESS
	return FAILURE
