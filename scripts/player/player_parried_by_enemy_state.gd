class_name PlayerParriedByEnemyState
extends PlayerStateMachine


@export var weapon: Sword

var _timer: Timer
var _timer_length: float = 0.4


func _ready():
	super._ready()
	
	weapon.parried.connect(
		func():
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
	_timer.start()
	player.attack_component.interrupt_attack()


func process_player():
	pass


func exit():
	_timer.stop()
