class_name CheckpointSystem
extends Node


@export var level: Node3D
@export var current_checkpoint: Checkpoint
@export var enemies: Node3D

var closest_checkpoint: Checkpoint

var checkpoints: Array[Checkpoint]

var near_checkpoint: bool = false
var at_checkpoint: bool = false

var _counter: int = 0
var _packed_enemies: PackedScene

@onready var player: Player = Globals.player
@onready var camera_controller: CameraController = Globals.camera_controller
@onready var lock_on_system: LockOnSystem = Globals.lock_on_system
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
	
	checkpoint_interface.perform_recovery.connect(
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
	
	if closest_checkpoint == null:
		closest_checkpoint = checkpoints[0]
	
	for checkpoint in checkpoints:
		var current_closest_checkpoint_dist: float = closest_checkpoint.global_position.distance_to(
			player.global_position
		)
		
		var checkpoint_dist: float = checkpoint.global_position.distance_to(
			player.global_position
		)
		
		if checkpoint_dist < current_closest_checkpoint_dist:
			closest_checkpoint = checkpoint


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


func sat_at_checkpoint() -> void:
	current_checkpoint = closest_checkpoint


func recover_after_death() -> void:
	lock_on_system.reset_target()
	player.global_transform = current_checkpoint\
		.respawn_point\
		.global_transform
	camera_controller.global_rotation.y = current_checkpoint\
		.respawn_point\
		.global_rotation\
		.y
	_recover()


func _recover() -> void:
	enemies.queue_free()
	Globals.user_interface.hud.clear_enemy_hud_elements()
	
	var new_enemies: Node = _packed_enemies.instantiate()
	level.add_child(new_enemies)
	enemies = new_enemies
	
	player.health_component.health = player.health_component.max_health
	player.instability_component.instability = 0
