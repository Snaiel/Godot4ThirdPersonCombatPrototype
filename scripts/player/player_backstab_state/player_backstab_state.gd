class_name PlayerBackstabState
extends PlayerStateMachine

@export var prepare_state: PlayerBackstabPrepareState
@export var attack_state: PlayerBackstabAttackState

func _ready():
	super._ready()


func enter() -> void:
	change_state(prepare_state)

func process_player() -> void:
	if not player.melee_component.attacking and current_state == attack_state:
		parent_state.transition_to_default_state()
		return

func exit() -> void:
	pass
