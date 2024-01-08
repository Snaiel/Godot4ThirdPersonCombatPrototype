class_name PlayerBlockState
extends PlayerStateMachine


@export var parry_state: PlayerParryState
@export var attack_state: PlayerAttackState
@export var reduce_instability_rate: float = 0.8

var _can_reduce_instability: bool = true
var _pause_before_reducing_instability_timer: Timer
var _pause_before_reducing_instability_length: float = 2.0


func _ready():
	super._ready()
	
	_pause_before_reducing_instability_timer = Timer.new()
	_pause_before_reducing_instability_timer.wait_time = \
		_pause_before_reducing_instability_length
	_pause_before_reducing_instability_timer.autostart = false
	_pause_before_reducing_instability_timer.one_shot = true
	_pause_before_reducing_instability_timer.timeout.connect(
		func():
			_can_reduce_instability = true
	)
	add_child(_pause_before_reducing_instability_timer)
	
	player.hitbox_component.weapon_hit.connect(
		func(incoming_weapon: Sword):
			if parent_state.current_state == self:
				player.movement_component.knockback(
					incoming_weapon.get_entity().global_position
				)
				
				player.block_component.blocked()
				player.instability_component.process_block()
				
				_can_reduce_instability = false
				_pause_before_reducing_instability_timer.start()
	)


func enter():
	player.block_component.blocking = true
	player.attack_component.interrupt_attack()


func process_player():
	prints(_can_reduce_instability)
	if Input.is_action_just_pressed("block"):
		parent_state.change_state(parry_state)
		return
	
	if not Input.is_action_pressed("block") and \
	not player.parry_component.is_spamming():
		parent_state.transition_to_default_state()
		return
	
	if Input.is_action_just_pressed("attack"):
		parent_state.change_state(attack_state)
		return
	
	player.set_rotation_target_to_lock_on_target()
	
	if _can_reduce_instability:
		player.instability_component.instability -= reduce_instability_rate


func exit():
	player.block_component.blocking = false
