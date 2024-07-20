class_name PlayerHitByEnemyState
extends PlayerStateMachine


@export var attack_state: PlayerAttackState
@export var block_state: PlayerBlockState
@export var parry_state: PlayerParryState
@export var dizzy_state: PlayerDizzyState
@export var death_state: PlayerDeathState

@export var sfx: AudioStreamPlayer3D

var _incoming_damage_source: DamageSource

var _can_block_or_parry: bool = false

var _timer: Timer
var _timer_length: float = 0.8

var _pressed_attack: bool = false


func _ready():
	super._ready()
	
	player.hitbox_component.damage_source_hit.connect(
		func(incoming_damage_source: DamageSource):
			if not parent_state.current_state is PlayerParriedEnemyHitState and \
			not parent_state.current_state is PlayerParryState and \
			not parent_state.current_state is PlayerBlockState and \
			not parent_state.current_state is PlayerDizzyState:
				_incoming_damage_source = incoming_damage_source
				parent_state.change_state(self)
	)
	
	_timer = Timer.new()
	_timer.wait_time = _timer_length
	_timer.autostart = false
	_timer.one_shot = true
	_timer.timeout.connect(
		func():
			if parent_state.current_state != self: return
			if _pressed_attack:
				parent_state.change_state(attack_state)
			else:
				parent_state.transition_to_default_state()
	)
	add_child(_timer)


func enter() -> void:
	_can_block_or_parry = false
	
	player.health_component.incoming_damage(_incoming_damage_source)
	player.instability_component.increment_instability(
		_incoming_damage_source.damage_attributes.hit_instability
	)
	
	player.locomotion_component.can_move = false
	player.locomotion_component.knockback(
		_incoming_damage_source.damage_attributes.knockback,
		_incoming_damage_source.entity.global_position
	)
	player.character.hit_and_death_animations.hit()
	player.melee_component.interrupt_attack()
	
	_pressed_attack = false
	
	sfx.play()
	
	_timer.start()


func process_player() -> void:
	if not player.health_component.is_alive():
		parent_state.change_state(death_state)
		return
	
	if player.instability_component.is_full_instability():
		parent_state.change_state(dizzy_state)
		return
	
	if _timer.time_left <= 0.25:
		_can_block_or_parry = true
	
	if _can_block_or_parry:
		if Input.is_action_just_pressed("block"):
			parent_state.change_state(parry_state)
			return
		
		if Input.is_action_pressed("block"):
			parent_state.change_state(block_state)
			return
	
	if Input.is_action_just_pressed("attack"):
		_pressed_attack = true
	
	player.set_rotation_target_to_lock_on_target()


func process_movement_animations() -> void:
	player.character.idle_animations.active = player.lock_on_target != null
	player.character.movement_animations.dir = Vector3.ZERO


func exit() -> void:
	player.locomotion_component.can_move = true
	_timer.stop()
