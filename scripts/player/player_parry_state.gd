class_name PlayerParryState
extends PlayerStateMachine


@export var block_state: PlayerBlockState
@export var dizzy_finisher_state: PlayerStateMachine


func _ready():
	super._ready()
	
	player.hitbox_component.weapon_hit.connect(
		func(incoming_weapon: Weapon):
			if parent_state.current_state == self:
				player.locomotion_component.knockback(
					incoming_weapon.entity.global_position
				)
	)


func enter():
	player.parry_component.parry()
	player.block_component.blocking = true
	player.melee_component.interrupt_attack()


func process_player():
	if Input.is_action_just_pressed("block") and (
		not player.melee_component.attacking or \
		player.melee_component.stop_attacking()
	):
		print("PLEASE PARRY")
		player.parry_component.parry()
		return
	
	if not player.parry_component.in_parry_window:
		if Input.is_action_pressed("block"):
			parent_state.change_state(block_state)
		else:
			parent_state.transition_to_default_state()
		return
	
	player.set_rotation_target_to_lock_on_target()
	
	if Globals.dizzy_system.dizzy_victim:
		parent_state.change_state(dizzy_finisher_state)


func exit():
	player.block_component.blocking = false
