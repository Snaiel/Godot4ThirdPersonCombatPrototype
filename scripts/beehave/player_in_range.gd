extends ConditionLeaf

@export var range = 5

func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("player_dist", range) < range:
		return SUCCESS
	return FAILURE
