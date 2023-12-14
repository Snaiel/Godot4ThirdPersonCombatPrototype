class_name BlockComponent
extends Node3D


@export var movement_component: MovementComponent
@export var character: CharacterAnimations
@export var walk_speed_while_blocking: float = 0.8
@export var transparency: float = 0.7

var blocking: bool = false

@onready var _mesh: MeshInstance3D = $Mesh
@onready var anim: AnimationPlayer = $AnimationPlayer


func _physics_process(_delta: float) -> void:
	character.block_animations.process_block(blocking)
	
	if blocking:
		if movement_component.target_entity.is_on_floor():
			movement_component.speed = walk_speed_while_blocking
		_mesh.transparency = lerp(
			_mesh.transparency,
			transparency,
			0.2
		)
	elif not anim.is_playing():
		_mesh.transparency = lerp(
			_mesh.transparency,
			1.0,
			0.2
		)


func blocked() -> void:
	if not anim.is_playing():
		print("BLOCKED")
		anim.play("blocked")
