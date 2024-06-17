class_name ResetWait
extends ActionLeaf

@export var wait_id: int

func tick(_actor: Node, blackboard: Blackboard) -> int:
	blackboard.set_value("wait_" + str(wait_id), true)
	return SUCCESS
