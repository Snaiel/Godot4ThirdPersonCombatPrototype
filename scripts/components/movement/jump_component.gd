class_name JumpComponent
extends Node3D


signal just_landed


@export_category("Configuration")
@export var entity: CharacterBody3D
@export var animations: CharacterAnimations
@export var rotation_component: RotationComponent
@export var locomotion_component: LocomotionComponent
@export var jump_strength: float = 8

@export_category("Audio")
@export var jump_sfx: AudioStreamPlayer3D
@export var land_sfx: AudioStreamPlayer3D

var jumping: bool = false
var about_to_land: bool = false

var _can_emit_just_landed: bool = true

@onready var _pivot: Node3D = $Pivot
@onready var _jump_raycast: RayCast3D = $Pivot/JumpRaycast


func _ready():
	animations.jump_animations.jumped.connect(_jump)
	animations.jump_animations.vertical_movement_ended.connect(_receive_vertical_movement_ended)


func _process(_delta: float) -> void:
	# align y axis to vector
	# https://kidscancode.org/godot_recipes/3.x/3d/3d_align_surface/
	var t: Transform3D = _pivot.global_transform
	if entity.velocity.length() > 0:
		var direction = entity.velocity.normalized()
		t.basis.y = -direction
		t.basis.x = t.basis.z.cross(direction)
		t.basis = t.basis.orthonormalized()
		_pivot.global_transform = t
	
	# if the player just walks off a platform, play the fall animation
	if not jumping: 
		if not entity.is_on_floor():
			_can_emit_just_landed = true
			if not _jump_raycast.is_colliding():
				animations.jump_animations.just_fall()
		else:
			animations.jump_animations.fade_out()
	
	about_to_land = not entity.is_on_floor() and \
		entity.velocity.y < -0.2 and \
		_jump_raycast.is_colliding() and \
		_jump_raycast.get_collision_normal().dot(Vector3.UP) > 0.7
	
	animations.jump_animations.about_to_land = about_to_land
	
	# Check if we're about to land on the floor
	if about_to_land:
		animations.jump_animations.jump_landing()
	
	# Check if we just landed on the floor
	if entity.is_on_floor() and _can_emit_just_landed:
		_can_emit_just_landed = false
		jumping = false
		animations.jump_animations.fade_out()
		just_landed.emit()
		land_sfx.play()



func start_jump() -> void:
	jumping = true
	animations.jump_animations.start_jump()


## the point in the animation where they lift off of the ground 
func _jump() -> void:
	jump_sfx.play()
	
	locomotion_component.desired_velocity.y = jump_strength
	locomotion_component.vertical_movement = true
	
	# wait before setting flag because just_landed
	# gets emitted while it is still on the ground.
	var timer: SceneTreeTimer = get_tree().create_timer(0.05)
	timer.timeout.connect(
		func():
			_can_emit_just_landed = true
	)


## assumes we are now not doing any vertical movement
func _receive_vertical_movement_ended() -> void:
	locomotion_component.can_disable_vertical_movement = true
	if rotation_component.move_direction.length() > 0.2:
		locomotion_component.vertical_movement = false
