class_name DizzyComponent
extends Node3D


@export_category("Dizzy Lengths")
@export var dizzy_from_parry_length: float = 2.0
@export var dizzy_from_damage_length: float = 3.0

@export_category("Configuration")
@export var debug: bool = false
@export var entity: CharacterBody3D
@export var lock_on_component: LockOnComponent
@export var health_component: HealthComponent
@export var movement_component: MovementComponent
@export var instability_component: InstabilityComponent
@export var character: CharacterAnimations
@export var blackboard: Blackboard

var _can_kill_dizzy_victim: bool = false

var _dizzy_timer: Timer

@onready var player: Player = Globals.player
@onready var dizzy_system: DizzySystem = Globals.dizzy_system


func _ready():
	if lock_on_component:
		position = lock_on_component.position
	
	health_component.zero_health.connect(
		func():
			dizzy_system.dizzy_victim = null
	)
	
	_dizzy_timer = Timer.new()
	_dizzy_timer.wait_time = dizzy_from_parry_length
	_dizzy_timer.autostart = false
	_dizzy_timer.one_shot = true
	_dizzy_timer.timeout.connect(_come_out_of_dizzy)
	add_child(_dizzy_timer)


func _on_hitbox_component_weapon_hit(weapon: Sword):
	if not _can_kill_dizzy_victim:
		var can_kill_timer: SceneTreeTimer = get_tree().create_timer(0.2)
		can_kill_timer.timeout.connect(
			func():
				_can_kill_dizzy_victim = true
		)
		return
	
	if dizzy_system.dizzy_victim == self and weapon.get_entity() == player:
		health_component.deal_max_damage = true
		dizzy_system.dizzy_victim_killed = true


func _on_instability_component_full_instability():
	blackboard.set_value("dizzy", true)
	blackboard.set_value("interrupt_timers", true)
	
	if dizzy_system.dizzy_victim == self:
		return
	
	dizzy_system.dizzy_victim = self
	dizzy_system.dizzy_victim_killed = false
	
	if instability_component.full_instability_from_parry:
		_can_kill_dizzy_victim = true
		character.dizzy_animations.dizzy_from_parry()
		_dizzy_timer.start(dizzy_from_parry_length)
		blackboard.set_value("look_at_target", true)
	else:
		_can_kill_dizzy_victim = false
		character.dizzy_animations.dizzy_from_damage()
		_dizzy_timer.start(dizzy_from_damage_length)
		blackboard.set_value("look_at_target", false)
		entity.look_at(player.global_position)
	
	var opponent_position: Vector3 = player.global_position
	var direction: Vector3 = global_position.direction_to(opponent_position)
	movement_component.set_secondary_movement(4, 5, 10, -direction)


func _come_out_of_dizzy() -> void:
	dizzy_system.dizzy_victim = null
	_can_kill_dizzy_victim = false
	character.dizzy_animations.disable_blend_dizzy()
	instability_component.come_out_of_full_instability(0.7)
	
	if instability_component.full_instability_from_parry:
		blackboard.set_value("dizzy", false)
	else:
		var come_out_of_damage_dizzy_timer: SceneTreeTimer = get_tree()\
			.create_timer(1.5)
		come_out_of_damage_dizzy_timer.timeout.connect(
			func():
				blackboard.set_value("dizzy", false)
		)
