extends ActionLeaf

@export var rotate_towards_target: bool = true

func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("rotate_towards_target") != rotate_towards_target:
		blackboard.set_value("rotate_towards_target", rotate_towards_target)
		return SUCCESS
	else:
		return FAILURE
