class_name JumpComponent
extends Node3D


signal just_landed


@export_category("Configuration")
@export var entity: CharacterBody3D
@export var animations: CharacterAnimations
@export var movement_component: MovementComponent
@export var jump_strength: float = 8

@export_category("Audio")
@export var jump_sfx: AudioStreamPlayer3D
@export var land_sfx: AudioStreamPlayer3D

var actually_jump: bool = false
var jumping: bool = false

var _can_emit_just_landed: bool = true

@onready var _jump_raycast: RayCast3D = $JumpRaycast


func _ready():
	animations.jump_animations.jumped.connect(_jump)
	animations.jump_animations.vertical_movement_ended.connect(_receive_vertical_movement_ended)


func _process(_delta: float) -> void:
	
	animations.jump_animations.about_to_land = _jump_raycast.is_colliding()
	
	# if the player just walks off a platform, play the fall animation
	if not jumping: 
		if not entity.is_on_floor():
			_can_emit_just_landed = true
			if not _jump_raycast.is_colliding():
				animations.jump_animations.just_fall()
		else:
			animations.jump_animations.fade_out()
	
	# Check if we're about to land on the floor
	if not entity.is_on_floor() and \
		entity.velocity.y < -0.2 and \
		_jump_raycast.is_colliding():
	
		animations.jump_animations.jump_landing()
	
	# Check if we just landed on the floor
	if entity.is_on_floor() and _can_emit_just_landed:
		_can_emit_just_landed = false
		jumping = false
		animations.jump_animations.fade_out()		
		just_landed.emit()
		land_sfx.play()
	
	# actually_jump is true when the jump animation reaches the point
	# where the animations actually jumps. When this happens,
	# apply the jumping force
	if actually_jump:
		actually_jump = false
		movement_component.desired_velocity.y = jump_strength
		movement_component.vertical_movement = true
		
		# wait before setting flag because just_landed
		# gets emitted while it is still on the ground.
		var timer: SceneTreeTimer = get_tree().create_timer(0.05)
		timer.timeout.connect(
			func():
				_can_emit_just_landed = true
		)


func start_jump() -> void:
	jumping = true
	animations.jump_animations.start_jump()


## the point in the animation where they lift off of the ground 
func _jump() -> void:
	actually_jump = true
	jump_sfx.play()


## assumes we are now not doing any vertical movement
func _receive_vertical_movement_ended() -> void:
	movement_component.can_disable_vertical_movement = true
	if movement_component.move_direction.length() > 0.2:
		movement_component.vertical_movement = false
