class_name BlockComponent
extends Node3D

@export var movement_component: MovementComponent
@export var block_animations: BlockAnimations
@export var attack_animations: AttackAnimations
@export var walk_speed_while_blocking = 0.8
@export var blocking = false
#	set = set_blocking
#
#var _can_set_blocking = true
#
#
#func _ready():
#	attack_animations.can_damage.connect(handle_can_damage)
#	attack_animations.attacking_finished.connect(handle_attack_finished)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	block_animations.block(blocking)
	movement_component.speed = walk_speed_while_blocking
#
#
#func set_blocking(flag: bool):
#	if _can_set_blocking:
#		blocking = flag
#
#
#func handle_can_damage(can_damage: bool):
#	if can_damage:
#		_can_set_blocking = false
#
#
#func handle_attack_finished():
#	_can_set_blocking = true
