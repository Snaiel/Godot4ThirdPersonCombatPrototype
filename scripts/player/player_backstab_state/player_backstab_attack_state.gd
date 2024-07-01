class_name PlayerBackstabAttackState
extends PlayerStateMachine

func _ready():
	super._ready()


func enter():
	player.rotation_component.rotate_towards_target = true
	player.melee_component.attack(2, true)
	player.hitbox_component.enabled = false
	player.locomotion_component.can_move = false

func exit():
	player.hitbox_component.enabled = true
	player.locomotion_component.can_move = true
