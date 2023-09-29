class_name JumpComponent
extends Node3D


@export var character: PlayerAnimations
@export var movement_component: MovementComponent
@export var jump_strength: float = 8

var can_jump: bool = false
var jumping: bool = false


func _process(_delta: float) -> void:
	# can_jump is true when the jump animation reaches the point
	# where the character actually jumps. When this happens,
	# apply the jumping force
	if can_jump:
		can_jump = false
		movement_component.desired_velocity.y = jump_strength
		movement_component.vertical_movement = true


func start_jump() -> void:
	jumping = true
	character.jump_animations.start_jump()


func jump() -> void:
	can_jump = true


func jump_landed() -> void:
	jumping = false
	movement_component.vertical_movement = false
