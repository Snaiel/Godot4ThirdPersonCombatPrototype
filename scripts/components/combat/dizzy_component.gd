class_name DizzyComponent
extends Node3D


@export_category("Configuration")
@export var debug: bool = false
@export var enabled: bool = true
@export var entity: Enemy

@export_category("Dizzy Lengths")
@export var dizzy_from_parry_length: float = 2.0
@export var dizzy_from_damage_length: float = 10

@export_category("Components")
@export var locomotion_component: LocomotionComponent
@export var health_component: HealthComponent
@export var melee_component: MeleeComponent
@export var instability_component: InstabilityComponent

@export_category("Utility")
@export var dizzy_victim_animations: DizzyVictimAnimations
@export var attachment_point: Node3D
@export var crosshair: Crosshair

@export_category("Audio")
@export var dizzy_sfx: AudioStreamPlayer3D
@export var thrust_puncture_sfx: AudioStreamPlayer3D
@export var hit_sfx: AudioStreamPlayer3D

var _dizzy_timer: Timer
var _come_out_of_damage_dizzy_timer: Timer
var _damage_dizzy_timer_pause: float = 1.5

@onready var player: Player = Globals.player
@onready var dizzy_system: DizzySystem = Globals.dizzy_system


func _ready():
	instability_component.full_instability.connect(
		_on_instability_component_full_instability
	)
	
	if crosshair: crosshair.register_callback(
		func():
			if dizzy_system.dizzy_victim == null: return false
			if dizzy_system.dizzy_victim != self: return false
			if dizzy_system.can_kill_victim: return true
			return false
	)
	
	_dizzy_timer = Timer.new()
	_dizzy_timer.wait_time = dizzy_from_parry_length
	_dizzy_timer.autostart = false
	_dizzy_timer.one_shot = true
	_dizzy_timer.timeout.connect(_come_out_of_dizzy)
	add_child(_dizzy_timer)
	
	_come_out_of_damage_dizzy_timer = Timer.new()
	_come_out_of_damage_dizzy_timer.wait_time = _damage_dizzy_timer_pause
	_come_out_of_damage_dizzy_timer.autostart = false
	_come_out_of_damage_dizzy_timer.one_shot = true
	_come_out_of_damage_dizzy_timer.timeout.connect(_back_to_normal)
	add_child(_come_out_of_damage_dizzy_timer)
	
	global_position = attachment_point.global_position


func _process(_delta):
	global_position = attachment_point.global_position
	if not enabled:
		if dizzy_system.dizzy_victim == self:
			dizzy_system.dizzy_victim = null
		return


func process_hit(weapon: DamageSource):
	if dizzy_system.dizzy_victim == self and weapon.entity == player:
		locomotion_component.set_active_strategy("root_motion")
		health_component.deal_max_damage = true
		dizzy_system.dizzy_victim_killed.emit()
		if instability_component.full_instability_from_parry:
			thrust_puncture_sfx.play()
		else:
			hit_sfx.play()


func _on_instability_component_full_instability(readied_finisher: bool):
	prints("WHAT THE HECK", readied_finisher)
	entity.beehave_tree.interrupt()
	entity.blackboard.set_value("dizzy", true)
	entity.beehave_tree.interrupt()
	
	_dizzy_timer.stop()
	_come_out_of_damage_dizzy_timer.stop()
	
	if dizzy_system.dizzy_victim == self: return
	dizzy_system.dizzy_victim = self
	dizzy_system.readied_finisher = readied_finisher
	
	dizzy_sfx.play()
	
	if instability_component.full_instability_from_parry:
		locomotion_component.set_active_strategy("root_motion")
		dizzy_victim_animations.dizzy_from_parry()
		_dizzy_timer.start(dizzy_from_parry_length)
		entity.blackboard.set_value("rotate_towards_target", true)
		_from_parry_knockback()
	else:
		dizzy_victim_animations.dizzy_from_damage()
		_dizzy_timer.start(dizzy_from_damage_length)
		entity.blackboard.set_value("rotate_towards_target", false)
		entity.look_at(player.global_position)
		_from_damage_knockback()
	
	if melee_component:
		melee_component.interrupt_attack()


func _from_parry_knockback() -> void:
	var opponent_position: Vector3 = player.global_position
	var direction: Vector3 = entity.global_position.direction_to(
		opponent_position
	)
	var distance: float = entity.global_position.distance_to(
		opponent_position
	)
	var weight: float = clamp(distance, 0.0, 2.0)
	weight = inverse_lerp(2.0, 0.0, weight)
	weight = lerp(0.0, 5.0, weight)
	locomotion_component.set_secondary_movement(
		weight,
		5,
		10,
		-direction
	)


func _from_damage_knockback() -> void:
	var opponent_position: Vector3 = player.global_position
	var direction: Vector3 = entity.global_position.direction_to(
		opponent_position
	)
	locomotion_component.set_secondary_movement(
		5,
		5,
		10,
		-direction
	)


func _come_out_of_dizzy() -> void:
	if not health_component.is_alive():
		return
	
	dizzy_system.dizzy_victim = null
	dizzy_victim_animations.disable_blend_dizzy()
	instability_component.come_out_of_full_instability(0.7)
	
	if instability_component.full_instability_from_parry:
		_back_to_normal()
	else:
		_come_out_of_damage_dizzy_timer.start()


func _back_to_normal() -> void:
	entity.blackboard.set_value("dizzy", false)
	locomotion_component.set_active_strategy("programmatic")
