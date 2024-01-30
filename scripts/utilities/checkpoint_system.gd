class_name CheckpointSystem
extends Node


@export var level: Node3D
@export var initial_checkpoint: Checkpoint
@export var enemies: Node3D

var current_checkpoint: Checkpoint
var saved_checkpoint: Checkpoint

var at_checkpoint: bool = false

var _packed_enemies: PackedScene

@onready var death_sfx: AudioStreamPlayer3D = $DeathSfx

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
	if not enemies:
		return
	
	_set_enemies_chldren_owner(enemies)
	
	_packed_enemies = PackedScene.new()
	_packed_enemies.pack(enemies)
	
	checkpoint_interface.perform_recovery.connect(
		_recover
	)
	
	saved_checkpoint = initial_checkpoint


func _physics_process(_delta: float):
	
	if current_checkpoint:
		interaction_hints.checkpoint_hint.visible = true
	else:
		interaction_hints.checkpoint_hint.visible = false
	
	if player.character.sitting_animations.sitting_idle:
		at_checkpoint = true
	else:
		at_checkpoint = false


func disable_hint() -> void:
	interaction_hints.counter -= 1


func enable_hint() -> void:
	interaction_hints.counter += 1


func save_current_checkpoint() -> void:
	saved_checkpoint = current_checkpoint


func play_death_sfx() -> void:
	death_sfx.play()


func recover_after_death() -> void:
	lock_on_system.reset_target()
	
	player.global_transform = saved_checkpoint\
		.respawn_point\
		.global_transform
	
	player.movement_component.reset_secondary_movement()
	player.movement_component.reset_desired_velocity()
	
	camera_controller.global_rotation.y = saved_checkpoint\
		.respawn_point\
		.global_rotation\
		.y
	
	_recover()


func _recover() -> void:
	enemies.queue_free()
	Globals.user_interface.hud.clear_enemy_hud_elements()
	Globals.camera_controller.reset()
	
	var new_enemies: Node = _packed_enemies.instantiate()
	level.add_child(new_enemies)
	enemies = new_enemies
	
	player.health_component.health = player.health_component.max_health
	player.instability_component.instability = 0
	player.health_charge_component.reset_charges()


func _set_enemies_chldren_owner(node: Node) -> void:
	for child in node.get_children():
		child.owner = enemies
		if child.get_child_count() > 0 and not child is Enemy:
			_set_enemies_chldren_owner(child)
