class_name BlockComponent
extends Node3D

@export var block_animations: BlockAnimations
@export var movement_component: MovementComponent
@export var walk_speed_while_blocking = 0.8
@export var blocking = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	block_animations.block(blocking)
	movement_component.speed = walk_speed_while_blocking
