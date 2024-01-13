class_name CheckpointSystem
extends Node


var at_checkpoint: bool = false

var _counter: int = 0

@onready var interaction_hints: InteractionHints = Globals\
	.user_interface\
	.hud\
	.interaction_hints


func _process(_delta):
	if _counter > 0:
		at_checkpoint = true
		interaction_hints.checkpoint_hint.visible = true
	else:
		at_checkpoint = false
		interaction_hints.checkpoint_hint.visible = false


func player_close_to_checkpoint() -> void:
	_counter += 1
	if _counter == 1:
		interaction_hints.counter += 1


func player_far_from_checkpoint() -> void:
	_counter -= 1
	if _counter == 0:
		interaction_hints.counter -= 1


func disable_hint() -> void:
	interaction_hints.counter -= 1


func enable_hint() -> void:
	interaction_hints.counter += 1
