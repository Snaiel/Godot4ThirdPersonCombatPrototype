class_name PatrolMoveSpeed
extends ActionLeaf


@export var min_speed: float
@export var max_speed: float
@export var min_dist: float
@export var max_dist: float


func tick(_actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("patrol_dist") == null: return SUCCESS
	
	var patrol_anim_speed: float = clamp(
		remap(
			blackboard.get_value("patrol_dist"),
			min_dist,
			max_dist,
			min_speed,
			max_speed
		),
		min_speed,
		max_speed
	)
	
	blackboard.set_value("anim_move_speed", patrol_anim_speed)
	return SUCCESS
