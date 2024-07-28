class_name PatrolMoveSpeed
extends ActionLeaf


@export var move_min_speed: float = 0
@export var move_max_speed: float = 3
@export var anim_min_speed: float = 0.2
@export var anim_max_speed: float = 1.0
@export var min_dist: float = 0.3
@export var max_dist: float = 2


func tick(_actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("patrol_dist") == null: return SUCCESS
	
	var patrol_dist: float = blackboard.get_value("patrol_dist")
	
	var patrol_anim_speed: float = clamp(
		remap(
			patrol_dist,
			min_dist,
			max_dist,
			anim_min_speed,
			anim_max_speed
		),
		anim_min_speed,
		anim_max_speed
	)
	
	var patrol_move_speed: float = clamp(
		remap(
			patrol_dist,
			min_dist,
			max_dist,
			move_min_speed,
			move_max_speed
		),
		move_min_speed,
		move_max_speed
	)
	
	blackboard.set_value("anim_move_speed", patrol_anim_speed)
	blackboard.set_value("move_speed", patrol_move_speed)
	
	return SUCCESS
