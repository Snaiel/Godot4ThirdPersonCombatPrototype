class_name SkipWait
extends ActionLeaf

@export var wait_id: int

func tick(_actor: Node, blackboard: Blackboard) -> int:
	blackboard.set_value("wait_" + str(wait_id), false)
	return SUCCESS
