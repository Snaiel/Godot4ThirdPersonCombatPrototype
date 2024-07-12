class_name PatrolMoveSpeed
extends ActionLeaf


@export var min_speed: float
@export var max_speed: float
@export var min_dist: float
@export var max_dist: float


func tick(_actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("patrol_dist") == null: return SUCCESS
	
	var patrol_anim_speed: float = lerp(
		min_speed,
		max_speed,
		clamp(
			inverse_lerp(
				min_dist,
				max_dist,
				blackboard.get_value("patrol_dist")
			),
			0.0,
			1.0
		)
	)
	
	print(patrol_anim_speed)
	blackboard.set_value("anim_move_speed", patrol_anim_speed)
	return SUCCESS
