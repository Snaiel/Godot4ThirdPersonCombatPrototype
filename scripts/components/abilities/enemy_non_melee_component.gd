class_name EnemyNonMeleeComponent
extends NonMeleeComponent


@export var blackboard: Blackboard


func _process(_delta: float) -> void:
	if blackboard.get_value("can_perform_action", false) and \
	blackboard.get_value("perform_action", false):
		blackboard.set_value("can_perform_action", false)
		blackboard.set_value("perform_action", false)
		action_index = blackboard.get_value("action_index", 0)
		perform_action(action_index)
	blackboard.set_value("executing_action", executing_action)
