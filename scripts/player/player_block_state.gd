class_name PlayerBlockState
extends PlayerStateMachine


@export var parry_state: PlayerParryState
@export var dodge_state: PlayerDodgeState
@export var attack_state: PlayerAttackState
@export var movement_animations: MovementAnimations

@export var blocking_sfx: AudioStreamPlayer
@export var block_sfx: AudioStreamPlayer3D

var _reduction_rate: float = 0.2
var _pause_before_reducing_instability_timer: Timer
var _pause_before_reducing_instability_length: float = 3.0

var _prev_anim_walk_speed: float


func _ready():
	super._ready()
	
	_pause_before_reducing_instability_timer = Timer.new()
	_pause_before_reducing_instability_timer.wait_time = \
		_pause_before_reducing_instability_length
	_pause_before_reducing_instability_timer.autostart = false
	_pause_before_reducing_instability_timer.one_shot = true
	_pause_before_reducing_instability_timer.timeout.connect(
		func():
			player.instability_component.reduce_instability = true
			player.instability_component.reduction_rate = _reduction_rate
	)
	add_child(_pause_before_reducing_instability_timer)
	
	player.hitbox_component.damage_source_hit.connect(
		func(incoming_damage_source: DamageSource):
			if parent_state.current_state != self: return
			
			player.locomotion_component.knockback(
				incoming_damage_source.damage_attributes.knockback,
				incoming_damage_source.entity.global_position
			)
			
			_pause_before_reducing_instability_timer.start()
			
			player.shield_component.blocked()
			player.instability_component.reset_reduction_rate()
			player.instability_component.increment_instability(
				incoming_damage_source.damage_attributes.block_instability
			)
			print(incoming_damage_source.damage_attributes.block_instability)
			
			block_sfx.play()
	)


func enter() -> void:
	player.shield_component.blocking = true
	player.melee_component.interrupt_attack()
	_pause_before_reducing_instability_timer.start()
	
	_prev_anim_walk_speed = movement_animations.speed
	
	blocking_sfx.play()


func process_player() -> void:
	if Input.is_action_just_pressed("block"):
		parent_state.change_state(parry_state)
		return
	
	if not Input.is_action_pressed("block") and \
	not player.parry_component.is_spamming():
		parent_state.transition_to_default_state()
		return
	
	if Input.is_action_just_pressed("run"):
		parent_state.change_state(dodge_state)
		return
	
	if Input.is_action_just_pressed("attack"):
		parent_state.change_state(attack_state)
		return
	
	player.set_rotation_target_to_lock_on_target()
	player.set_rotate_towards_target_if_lock_on_target()


func process_movement_animations() -> void:
	var locked_on: bool = player.lock_on_target != null
	player.character.idle_animations.active = locked_on
	var dir: Vector3 = player.input_direction
	if not locked_on and dir.length() > 0.05:
		dir = Vector3.FORWARD
	player.character.movement_animations.dir = dir
	player.character.movement_animations.set_state("walk")
	movement_animations.speed = 0.5


func exit() -> void:
	_pause_before_reducing_instability_timer.stop()
	player.instability_component.reset_reduction_rate()
	player.shield_component.blocking = false
	blocking_sfx.stop()
	movement_animations.speed = _prev_anim_walk_speed
