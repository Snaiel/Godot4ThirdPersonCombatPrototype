extends ActionLeaf

@export var look_at_target = true

func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("look_at_target") != look_at_target:
		blackboard.set_value("look_at_target", look_at_target)
		return SUCCESS
	else:
		return FAILURE
