class_name CheckpointSystem
extends Node


var near_checkpoint: bool = false
var at_checkpoint: bool = false

var _counter: int = 0

@onready var player: Player = Globals.player
@onready var interaction_hints: InteractionHints = Globals\
	.user_interface\
	.hud\
	.interaction_hints


func _process(_delta):
	if _counter > 0:
		near_checkpoint = true
		interaction_hints.checkpoint_hint.visible = true
	else:
		near_checkpoint = false
		interaction_hints.checkpoint_hint.visible = false
	
	if player.character.sitting_animations.sitting_idle:
		at_checkpoint = true
	else:
		at_checkpoint = false


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
