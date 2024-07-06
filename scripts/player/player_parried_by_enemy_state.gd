class_name PlayerParriedByEnemyState
extends PlayerStateMachine

@export var attack_state: PlayerAttackState

var _timer: Timer
var _timer_length: float = 0.4

var _pressed_attack: bool = false


func _ready():
	super._ready()
	
	player.weapon.parried.connect(
		func():
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


func enter() -> void:
	_timer.start()
	player.melee_component.interrupt_attack()
	_pressed_attack = false


func process_player() -> void:
	if Input.is_action_just_pressed("attack"):
		_pressed_attack = true


func exit() -> void:
	_timer.stop()
