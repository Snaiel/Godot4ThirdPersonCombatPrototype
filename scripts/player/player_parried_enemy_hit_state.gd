class_name PlayerParriedEnemyHitState
extends PlayerStateMachine


@export var locomotion_component: LocomotionComponent

@export var attack_state: PlayerAttackState
@export var block_state: PlayerBlockState
@export var parry_state: PlayerParryState
@export var dizzy_finisher_state: PlayerDizzyFinisherState

@export var sfx: AudioStreamPlayer3D

var _incoming_damage_source: DamageSource

var _timer: Timer
var _timer_length: float = 0.5


func _ready():
	super._ready()
	
	player.parry_component.parried_incoming_hit.connect(
		func(incoming_damage_source: DamageSource):
			_incoming_damage_source = incoming_damage_source
			if Globals.dizzy_system.dizzy_victim == null:
				parent_state.change_state(self)
	)
	
	player.hitbox_component.damage_source_hit.connect(
		func(_damage_source: DamageSource):
			if parent_state.current_state != self: return
			block_state.block_sfx.play()
			player.block_component.blocking = true
			player.block_component.blocked()
	)
	
	_timer = Timer.new()
	_timer.wait_time = _timer_length
	_timer.autostart = false
	_timer.one_shot = true
	_timer.timeout.connect(
		func(): parent_state.transition_to_default_state()
	)
	add_child(_timer)


func enter() -> void:
	locomotion_component.speed = 3
	player.block_component.blocking = true
	
	player.instability_component.process_parry()
	
	player.parry_component.reset_parry_cooldown()
	player.parry_component.play_parry_particles()
	
	player.character.parry_animations.parry()
	
	player.block_component.anim.stop()
	player.block_component.anim.play("parried")
	
	_incoming_damage_source.get_parried()
	if not player.dizzy_system.dizzy_victim:
		player.locomotion_component.knockback(
			_incoming_damage_source.entity.global_position
		)
	
	sfx.play()
	
	_timer.start()


func process_player() -> void:
	if Globals.dizzy_system.dizzy_victim:
		parent_state.change_state(dizzy_finisher_state)
		return
	
	if Input.is_action_just_pressed("attack"):
		parent_state.change_state(attack_state)
		return
		
	if Input.is_action_just_pressed("block"):
		parent_state.change_state(parry_state)
		return


func exit() -> void:
	player.block_component.blocking = false
	_timer.stop()
