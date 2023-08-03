class_name BlockComponent
extends Node3D

@export var movement_component: MovementComponent
@export var block_animations: BlockAnimations
@export var attack_animations: AttackAnimations
@export var walk_speed_while_blocking = 0.8
@export var blocking = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	block_animations.block(blocking)
	if blocking and movement_component.target_entity.is_on_floor():
		movement_component.speed = walk_speed_while_blocking
