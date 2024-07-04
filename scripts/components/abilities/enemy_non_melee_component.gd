class_name EnemyNonMeleeComponent
extends NonMeleeComponent


@export var blackboard: Blackboard


func _ready() -> void:
	super()


func _process(_delta: float) -> void:
	if blackboard.get_value("can_perform_action", false) and \
	blackboard.get_value("perform_action", false):
		blackboard.set_value("can_perform_action", false)
		blackboard.set_value("perform_action", false)
		action_index = blackboard.get_value("action_index", 0)
		perform_action(action_index)
	blackboard.set_value("executing_action", executing_action)


func _receive_action_effect(index: int) -> void:
	var child = get_child(index)
	if not (child is NonMeleeActionEffect): return
	var effect: NonMeleeActionEffect = child
	effect.effect()


func _receive_end_effect(index: int) -> void:
	var child = get_child(index)
	if not (child is NonMeleeActionEffect): return
	var effect: NonMeleeActionEffect = child
	effect.end()
