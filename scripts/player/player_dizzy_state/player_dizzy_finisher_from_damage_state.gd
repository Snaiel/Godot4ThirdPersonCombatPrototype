class_name PlayerDizzyFinisherFromDamageState
extends PlayerStateMachine


var _can_set_damage: bool = false
var _finished: bool = false

@onready var dizzy_system: DizzySystem = Globals.dizzy_system


func _ready():
	super._ready()
	
	player.character.dizzy_animations.dizzy_finisher_finished.connect(
		func():
			_finished = true
	)
	
	player.character.attack_animations.can_damage.connect(
		func(_flag: bool):
			_can_set_damage = true
	)


func enter():
	_finished = false
	player.movement_component.can_move = false
	player.weapon.can_damage = false
	player.attack_component.disable_attack_interrupted()
	player.character.dizzy_animations.play_from_damage_finisher()
	dizzy_system.victim_being_killed = true

func process_player():
	if _can_set_damage:
		player.weapon.can_damage = true
	
	if _finished:
		parent_state.parent_state.transition_to_default_state()
		return


func exit():
	player.movement_component.can_move = true
	dizzy_system.victim_being_killed = false
