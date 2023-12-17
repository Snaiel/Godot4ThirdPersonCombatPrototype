class_name DizzyComponent
extends Node3D


@export var debug: bool = false
@export var entity: CharacterBody3D
@export var lock_on_component: LockOnComponent
@export var health_component: HealthComponent
@export var movement_component: MovementComponent
@export var character: CharacterAnimations
@export var blackboard: Blackboard

@onready var player: Player = Globals.player
@onready var dizzy_system: DizzySystem = Globals.dizzy_system


func _ready():
	if lock_on_component:
		position = lock_on_component.position
	
	health_component.zero_health.connect(
		func():
			dizzy_system.dizzy_victim = null
	)


func _on_hitbox_component_weapon_hit(_weapon: Sword):
	if dizzy_system.dizzy_victim == self:
		health_component.deal_max_damage = true


func _on_instability_component_full_instability(flag: bool):
	blackboard.set_value("dizzy", flag)
	blackboard.set_value("interrupt_timers", true)
	character.dizzy_animations.dizzy_from_parry(flag)
	dizzy_system.dizzy_victim = self if flag else null
	
	if flag:
		var opponent_position: Vector3 = player.global_position
		var direction: Vector3 = global_position.direction_to(opponent_position)
		movement_component.set_secondary_movement(4, 5, 10, -direction)
