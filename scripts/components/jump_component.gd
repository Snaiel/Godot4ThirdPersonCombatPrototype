class_name JumpComponent
extends Node3D


signal just_landed


@export var entity: CharacterBody3D
@export var animations: PlayerAnimations
@export var movement_component: MovementComponent
@export var jump_strength: float = 8

var can_jump: bool = false
var jumping: bool = false

var _can_emit_just_landed: bool = true

func _ready():
	animations.jump_animations.jumped.connect(jump)
	animations.jump_animations.jump_landed.connect(jump_landed)
	

func _process(_delta: float) -> void:
	
	if entity.is_on_floor() and _can_emit_just_landed:
		_can_emit_just_landed = false
		animations.jump_animations.fade_out()
		just_landed.emit()
	
	# can_jump is true when the jump animation reaches the point
	# where the animations actually jumps. When this happens,
	# apply the jumping force
	if can_jump:
		can_jump = false
		movement_component.desired_velocity.y = jump_strength
		movement_component.vertical_movement = true
		_can_emit_just_landed = true		


func start_jump() -> void:
	jumping = true
	animations.jump_animations.start_jump()


# the point in the animation where they lift
# off of the ground 
func jump() -> void:
	can_jump = true


# the point in the animation where they touch
# the ground
func jump_landed() -> void:
	jumping = false
	movement_component.vertical_movement = false
