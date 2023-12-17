class_name DizzyComponent
extends Node3D


@export var debug: bool = false
@export var entity: CharacterBody3D
@export var lock_on_component: LockOnComponent
@export var health_component: HealthComponent
@export var character: CharacterAnimations
@export var blackboard: Blackboard
@export var instability_component: InstabilityComponent

@onready var dizzy_system: DizzySystem = Globals.dizzy_system


func _ready():
	if lock_on_component:
		position = lock_on_component.position
	
	instability_component.full_instability.connect(
		func(flag: bool):
			blackboard.set_value("dizzy", flag)
			blackboard.set_value("interrupt_timers", true)
			character.dizzy_animations.dizzy_from_parry(flag)
			dizzy_system.dizzy_victim = self if flag else null
	)
	
	health_component.zero_health.connect(
		func():
			dizzy_system.dizzy_victim = null
	)


func _on_hitbox_component_weapon_hit(_weapon: Sword):
	if dizzy_system.dizzy_victim == self:
		health_component.deal_max_damage = true
