class_name BlockComponent
extends Node3D

@export var entity: CharacterBody3D
@export var locomotion_component: LocomotionComponent
@export var block_animations: BlockAnimations
@export var walk_speed_while_blocking: float = 0.8
@export var transparency: float = 0.7
@export var block_particles_scene: PackedScene = preload("res://scenes/particles/BlockParticles.tscn")

var blocking: bool = false:
	set = set_blocking

var _particles: GPUParticles3D

@onready var mesh: MeshInstance3D = $Mesh
@onready var anim: AnimationPlayer = $AnimationPlayer


func _ready():
	_particles = block_particles_scene.instantiate()
	add_child(_particles)


func _physics_process(_delta: float) -> void:
	block_animations.process_block(blocking)
	
	if blocking:
		if entity.is_on_floor():
			locomotion_component.speed = walk_speed_while_blocking
		mesh.transparency = lerp(
			mesh.transparency,
			transparency,
			0.2
		)
	elif not anim.is_playing():
		mesh.transparency = lerp(
			mesh.transparency,
			1.0,
			0.2
		)


func set_blocking(value: bool) -> void:
	if value == blocking: return
	blocking = value


func blocked() -> void:
	if anim.current_animation != "blocked":
		print("BLOCKED")
		blocking = true
		anim.play("blocked")
	_particles.restart()
