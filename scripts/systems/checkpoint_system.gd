class_name CheckpointSystem
extends Node


@export var levels: Array[Node3D]
@export var initial_checkpoint: Checkpoint

var current_checkpoint: Checkpoint
var saved_checkpoint: Checkpoint

var at_checkpoint: bool = false

var _packed_enemies: Array[PackedScene]
var _enemies: Array[Node3D]

@onready var death_sfx: AudioStreamPlayer = $DeathSfx

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
	for level in levels:
		var enemies = level.get_node("Enemies")
		_enemies.append(enemies)
		set_node_owner_to_enemies(enemies, enemies)
		var packed_enemies = PackedScene.new()
		_packed_enemies.append(packed_enemies)
		packed_enemies.pack(enemies)
	
	checkpoint_interface.perform_recovery.connect(
		_recover
	)
	
	saved_checkpoint = initial_checkpoint


func _physics_process(_delta: float):
	interaction_hints.checkpoint_hint.visible = current_checkpoint != null
	at_checkpoint = player.character.sit_animations.sitting_idle


func set_node_owner_to_enemies(node: Node, enemies: Node) -> void:
	for child in node.get_children():
		child.owner = enemies
		if child.get_child_count() > 0 and not child is Enemy:
			set_node_owner_to_enemies(child, enemies)


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
	
	player.locomotion_component.reset_secondary_movement()
	player.locomotion_component.reset_desired_velocity()
	
	camera_controller.global_rotation.y = saved_checkpoint\
		.respawn_point\
		.global_rotation\
		.y
	
	_recover()


func _recover() -> void:
	Globals.camera_controller.reset()
	
	for enemies in _enemies:
		for child in enemies.get_children():
			if not child is EnemySection: continue
			var section: EnemySection = child
			section.free_enemies()
		enemies.queue_free()
	
	Globals.user_interface.hud.clear_enemy_hud_elements()
	
	for i in range(len(levels)):
		var new_enemies: Node = _packed_enemies[i].instantiate()
		levels[i].add_child(new_enemies)
		_enemies[i] = new_enemies
	
	player.health_component.health = player.health_component.max_health
	player.instability_component.instability = 0
	player.health_charge_component.reset_charges()
