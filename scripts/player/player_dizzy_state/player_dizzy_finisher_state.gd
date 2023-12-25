class_name PlayerDizzyFinisherState
extends PlayerStateMachine


@export var from_parry: PlayerDizzyFinisherFromParryState
@export var from_damage: PlayerDizzyFinisherFromDamageState

@onready var dizzy_system: DizzySystem = Globals.dizzy_system

func _ready():
	super._ready()


func enter():
	player.hitbox_component.enabled = false
	player.movement_component.speed = 3
	
	var state: PlayerStateMachine
	if dizzy_system.dizzy_victim.instability_component.full_instability_from_parry:
		state = from_parry
	else:
		state = from_damage
	
	if current_state != state:
		change_state(state)


func process_player():
	pass


func exit():
	player.hitbox_component.enabled = true
