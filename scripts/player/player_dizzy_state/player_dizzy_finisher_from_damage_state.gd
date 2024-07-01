class_name PlayerDizzyFinisherFromDamageState
extends PlayerStateMachine


var _finished: bool = false

@onready var dizzy_system: DizzySystem = Globals.dizzy_system


func _ready():
	super._ready()
	
	player.character.dizzy_finisher_animations.dizzy_finisher_finished.connect(
		func():
			if parent_state.current_state != self:
				return
			
			_finished = true
	)


func enter():
	_finished = false
	player.locomotion_component.can_move = false
	player.weapon.can_damage = false
	player.melee_component.instance += 1
	player.melee_component.disable_attack_interrupted()
	player.character.dizzy_finisher_animations.play_from_damage_finisher()
	dizzy_system.victim_being_killed = true


func process_player():
	if _finished:
		parent_state.parent_state.transition_to_default_state()
		return


func exit():
	player.locomotion_component.can_move = true
	dizzy_system.victim_being_killed = false
