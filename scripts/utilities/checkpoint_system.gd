class_name CheckpointSystem
extends Node


@export var enemies: Node

var near_checkpoint: bool = false
var at_checkpoint: bool = false

var _counter: int = 0
var _packed_enemies: PackedScene

@onready var player: Player = Globals.player
@onready var interaction_hints: InteractionHints = Globals\
	.user_interface\
	.hud\
	.interaction_hints
@onready var checkpoint_interface: CheckpointInterface = Globals\
	.user_interface\
	.checkpoint_interface


func _ready():
	for child in enemies.get_children():
		child.owner = enemies
	
	_packed_enemies = PackedScene.new()
	_packed_enemies.pack(enemies)
	
	checkpoint_interface.recover_button.pressed.connect(
		_recover
	)

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


func _recover() -> void:
	enemies.queue_free()
	var new_enemies: Node = _packed_enemies.instantiate()
	get_parent().add_child(new_enemies)
	enemies = new_enemies
	
	player.health_component.health = player.health_component.max_health
	player.instability_component.instability = 0
