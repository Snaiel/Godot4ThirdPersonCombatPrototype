class_name DizzyComponent
extends Node3D


@export var debug: bool = false
@export var entity: CharacterBody3D
@export var lock_on_component: LockOnComponent
@export var health_component: HealthComponent
@export var movement_component: MovementComponent
@export var instability_component: InstabilityComponent
@export var character: CharacterAnimations
@export var blackboard: Blackboard

var _can_kill_dizzy_victim: bool = false

@onready var player: Player = Globals.player
@onready var dizzy_system: DizzySystem = Globals.dizzy_system


func _ready():
	if lock_on_component:
		position = lock_on_component.position
	
	health_component.zero_health.connect(
		func():
			dizzy_system.dizzy_victim = null
	)


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


func _on_instability_component_full_instability(flag: bool):
	blackboard.set_value("dizzy", flag)
	blackboard.set_value("interrupt_timers", true)
	
	
	if flag:
		if dizzy_system.dizzy_victim == self:
			return
		
		dizzy_system.dizzy_victim = self
		dizzy_system.dizzy_victim_killed = false
		
		if instability_component.full_instability_from_parry:
			_can_kill_dizzy_victim = true
			character.dizzy_animations.dizzy_from_parry()
		else:
			_can_kill_dizzy_victim = false
			character.dizzy_animations.dizzy_from_damage()
		
		var opponent_position: Vector3 = player.global_position
		var direction: Vector3 = global_position.direction_to(opponent_position)
		movement_component.set_secondary_movement(4, 5, 10, -direction)
	else:
		dizzy_system.dizzy_victim = null
		character.dizzy_animations.disable_blend_dizzy()
		_can_kill_dizzy_victim = false
