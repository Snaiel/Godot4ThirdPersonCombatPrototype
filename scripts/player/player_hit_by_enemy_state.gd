class_name PlayerHitByEnemyState
extends PlayerStateMachine


@export var attack_state: PlayerAttackState
@export var block_state: PlayerBlockState
@export var parry_state: PlayerParryState

@export var sfx: AudioStreamPlayer3D

var _incoming_weapon: Weapon

var _can_block_or_parry: bool = false

var _timer: Timer
var _timer_length: float = 0.8

var _pressed_attack: bool = false


func _ready():
	super._ready()
	
	player.hitbox_component.weapon_hit.connect(
		func(incoming_weapon: Weapon):
			if not parent_state.current_state is PlayerParriedEnemyHitState and \
			not parent_state.current_state is PlayerParryState and \
			not parent_state.current_state is PlayerBlockState:
				_incoming_weapon = incoming_weapon
				parent_state.change_state(self)
	)
	
	_timer = Timer.new()
	_timer.wait_time = _timer_length
	_timer.autostart = false
	_timer.one_shot = true
	_timer.timeout.connect(
		func():
			if _pressed_attack:
				parent_state.change_state(attack_state)
			else:
				parent_state.transition_to_default_state()
	)
	add_child(_timer)


func enter():
	_can_block_or_parry = false
	
	player.locomotion_component.can_move = false
	player.locomotion_component.knockback(
		_incoming_weapon.entity.global_position
	)
	player.character.hit_and_death_animations.hit()
	player.attack_component.interrupt_attack()
	
	_pressed_attack = false
	
	sfx.play()
	
	_timer.start()


func process_player():
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
	player.character.movement_animations.move(
		Vector3.ZERO,
		player.lock_on_target != null, 
		false
	)


func exit():
	player.locomotion_component.can_move = true
	_timer.stop()
