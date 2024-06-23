class_name SetRootMotion
extends ActionLeaf


@export var entity: Enemy
@export var root_motion: bool = false


func tick(_actor: Node, _blackboard: Blackboard) -> int:
	entity.set_root_motion(root_motion)
	return SUCCESS
