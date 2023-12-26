class_name PlayerHitByEnemyState
extends PlayerStateMachine


var _incoming_weapon: Sword

var _timer: Timer
var _timer_length: float = 0.8


func _ready():
	super._ready()
	
	player.hitbox_component.weapon_hit.connect(
		func(incoming_weapon: Sword):
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
			parent_state.transition_to_default_state()
	)
	add_child(_timer)


func enter():
	player.movement_component.can_move = false
	player.movement_component.knockback(
		_incoming_weapon.get_entity().global_position
	)
	player.character.hit_and_death_animations.hit()
	player.attack_component.interrupt_attack()
	_timer.start()


func process_player():
	player.set_rotation_target_to_lock_on_target()


func exit():
	player.movement_component.can_move = true
	_timer.stop()
