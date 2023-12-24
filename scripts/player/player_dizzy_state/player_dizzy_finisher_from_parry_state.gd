class_name PlayerDizzyFinisherFromParryState
extends PlayerStateMachine


var _finished: bool = false

@onready var dizzy_system: DizzySystem = Globals.dizzy_system


func _ready():
	super._ready()
	
	player.character.dizzy_animations.dizzy_finisher_finished.connect(
		func():
			_finished = true
	)


func enter():
	_finished = false
	player.character.dizzy_animations.play_from_parry_pre_finisher()
	player.look_at(dizzy_system.dizzy_victim.entity.global_position)
	player.rotation_component.target = Globals.dizzy_system.dizzy_victim.entity
	player.rotation_component.rotate_towards_target = true
	player.can_move = false
	player.fade_component.enabled = false
	player.character.parry_animations.receive_parry_finished()


func process_player():
	if Input.is_action_just_pressed("attack") and \
	dizzy_system.can_kill_victim:
		player.attack_component.disable_attack_interrupted()
		player.character.dizzy_animations.play_from_parry_finisher()
		dizzy_system.victim_being_killed = true
	
	if not dizzy_system.victim_being_killed and \
	dizzy_system.saved_victim != null and \
	dizzy_system.saved_victim.instability_component.full_instability_from_parry:
		player.character.dizzy_animations.receive_dizzy_finisher_finished()
	
	if _finished:
		parent_state.parent_state.transition_to_default_state()
		return


func exit():
	player.movement_component.can_move = true
	dizzy_system.victim_being_killed = false
