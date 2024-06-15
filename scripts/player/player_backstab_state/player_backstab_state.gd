class_name PlayerBackstabState
extends PlayerStateMachine

@export var prepare_state: PlayerBackstabPrepareState
@export var attack_state: PlayerBackstabAttackState

func _ready():
	super._ready()


func enter():
	change_state(prepare_state)

func process_player():
	if not player.attack_component.attacking and current_state == attack_state:
		parent_state.change_state(parent_state.default_state)
		return

func exit():
	pass
