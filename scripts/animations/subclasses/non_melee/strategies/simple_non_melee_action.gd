class_name SimpleNonMeleeAction
extends NonMeleeAction


@export var action_name: String
@export var has_copy: bool = false

@export_category("Animation Settings")
@export var trim: float = 0.0
@export var animation_speed: float = 1.0


func play_animation():
	if not has_copy:
		_play_action()
		return
	
	_play_action(_play_copy)
	_play_copy = not _play_copy


func _play_action(copy: bool = false):
	var prefix = "parameters/%s%s/%s " % [
		action_name, " Copy" if copy else "", action_name
	]
	anim_tree.set(
		prefix + "Trim/seek_request",
		 trim
	)
	anim_tree.set(
		prefix + "Speed/scale",
		 animation_speed
	)
	anim_tree.set(
		"parameters/NonMeleeAction/transition_request",
		 action_name.to_snake_case() + ("_copy" if copy else "")
	)
