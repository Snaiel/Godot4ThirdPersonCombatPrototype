class_name PlayerBackstabAttackState
extends PlayerStateMachine

func _ready():
	super._ready()


func enter():
	player.rotation_component.rotate_towards_target = true
	player.attack_component.thrust()
	player.hitbox_component.enabled = false
	player.movement_component.can_move = false

func exit():
	player.hitbox_component.enabled = true
	player.movement_component.can_move = true
