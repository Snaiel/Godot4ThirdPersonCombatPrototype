class_name PlayerBlockState
extends PlayerStateMachine


@export var parry_state: PlayerParryState
@export var attack_state: PlayerAttackState


func _ready():
	super._ready()
	
	player.hitbox_component.weapon_hit.connect(
		func(incoming_weapon: Sword):
			if parent_state.current_state == self:
				player.movement_component.knockback(
					incoming_weapon.get_entity().global_position
				)
				player.block_component.blocked()
	)


func enter():
	player.block_component.blocking = true
	player.attack_component.interrupt_attack()


func process_player():
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


func exit():
	player.block_component.blocking = false
