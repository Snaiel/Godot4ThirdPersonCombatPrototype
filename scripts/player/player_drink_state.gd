class_name PlayerDrinkState
extends PlayerStateMachine


@export var health_charge_component: HealthChargeComponent


func _ready():
	super._ready()
	
	health_charge_component.finished_drinking.connect(
		func():
			parent_state.transition_to_default_state()
	)


func enter():
	health_charge_component.consume_health_charge()
	player.head_rotation_component.enabled = false
	player.movement_component.speed = 0.8


func process_player():
	pass


func exit():
	player.head_rotation_component.enabled = true
