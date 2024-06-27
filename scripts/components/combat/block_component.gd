class_name BlockComponent
extends Node3D

@export var entity: CharacterBody3D
@export var programmatic_movement: ProgrammaticMovementLocomotionStrategy
@export var character: CharacterAnimations
@export var walk_speed_while_blocking: float = 0.8
@export var transparency: float = 0.7
@export var block_particles_scene: PackedScene = preload("res://scenes/particles/BlockParticles.tscn")

var blocking: bool = false

var _particles: GPUParticles3D

@onready var _mesh: MeshInstance3D = $Mesh
@onready var anim: AnimationPlayer = $AnimationPlayer


func _ready():
	_particles = block_particles_scene.instantiate()
	add_child(_particles)


func _physics_process(_delta: float) -> void:
	character.block_animations.process_block(blocking)
	
	if blocking:
		if entity.is_on_floor():
			programmatic_movement.speed = walk_speed_while_blocking
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
	_particles.restart()
