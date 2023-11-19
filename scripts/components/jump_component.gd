class_name JumpComponent
extends Node3D


signal just_landed


@export var entity: CharacterBody3D
@export var animations: PlayerAnimations
@export var movement_component: MovementComponent
@export var jump_strength: float = 8

var actually_jump: bool = false
var jumping: bool = false

var _can_emit_just_landed: bool = true

@onready var _jump_raycast: RayCast3D = $JumpRaycast

func _ready():
	animations.jump_animations.jumped.connect(jump)


func _process(_delta: float) -> void:
	
	animations.jump_animations.about_to_land = _jump_raycast.is_colliding()
	
	# Check if we're about to land on the floor
	if not entity.is_on_floor() and \
		entity.velocity.y < -0.2 and \
		_jump_raycast.is_colliding():

		animations.jump_animations.jump_landing()
	
	# Check if we just landed on the floor
	if entity.is_on_floor() and _can_emit_just_landed:
		_can_emit_just_landed = false
		jumping = false
		movement_component.vertical_movement = false
		animations.jump_animations.fade_out()		
		just_landed.emit()
	
	# actually_jump is true when the jump animation reaches the point
	# where the animations actually jumps. When this happens,
	# apply the jumping force
	if actually_jump:
		actually_jump = false
		movement_component.desired_velocity.y = jump_strength
		movement_component.vertical_movement = true
		_can_emit_just_landed = true


func start_jump() -> void:
	jumping = true
	animations.jump_animations.start_jump()


# the point in the animation where they lift
# off of the ground 
func jump() -> void:
	actually_jump = true
