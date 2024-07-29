extends ActionLeaf


var _turning_back: bool = true
var _done: bool = false

func before_run(_actor: Node, blackboard: Blackboard) -> void:
	if blackboard.get_value("dist_original_position") > 2.0:
		_turning_back = false
		_done = false


func tick(actor: Node, blackboard: Blackboard) -> int:
	var entity: Enemy = actor
	var dist_original = blackboard.get_value("dist_original_position")
	
	if _done: return SUCCESS
	
	if not _turning_back and dist_original > 0.6:
		blackboard.set_value(
			"agent_target_position",
			blackboard.get_value("original_position")
		)
		entity.locomotion_component.set_active_strategy("root_motion")
		blackboard.set_value("rotate_towards_target", true)
		blackboard.set_value("anim_move_speed", 1.0)
		blackboard.set_value("input_direction", Vector3.FORWARD)
	else:
		_turning_back = true
		blackboard.set_value(
			"agent_target_position",
			blackboard.get_value("original_position") + \
				Vector3.FORWARD.rotated(
					Vector3.UP,
					blackboard.get_value("original_rotation")
				) * 2
		)
		get_tree().create_timer(0.5).timeout.connect(
			func():
				blackboard.set_value("input_direction", Vector3.ZERO)
				_done = true
		)
	return RUNNING
