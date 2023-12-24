class_name PlayerDizzyFinisherState
extends PlayerStateMachine


@export var from_parry: PlayerDizzyFinisherFromParryState
@export var from_damage: PlayerDizzyFinisherFromDamageState

@onready var dizzy_system: DizzySystem = Globals.dizzy_system

func _ready():
	super._ready()


func enter():
	player.movement_component.speed = 3
	
	if dizzy_system.dizzy_victim.instability_component.full_instability_from_parry:
		change_state(from_parry)
	else:
		change_state(from_damage)


func process_player():
	pass


func exit():
	pass

