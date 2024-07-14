class_name BlockComponent
extends Node3D


@export var debug: bool = false
@export var entity: CharacterBody3D
@export var locomotion_component: LocomotionComponent
@export var block_animations: BlockAnimations
@export var walk_speed_while_blocking: float = 0.8
@export var block_particles_scene: PackedScene = preload(
	"res://scenes/particles/BlockParticles.tscn"
)

@export var opacity: float = 0.0

var animating_opacity: bool = false
var blocking: bool = false:
	set(value):
		if value == blocking: return
		blocking = value

var _particles: GPUParticles3D

@onready var mesh: MeshInstance3D = $Mesh
@onready var anim: AnimationPlayer = $AnimationPlayer


func _ready():
	_particles = block_particles_scene.instantiate()
	opacity = 0


func _physics_process(_delta: float) -> void:
	#if debug: prints(
		#opacity,
		#mesh.get_instance_shader_parameter("opacity")
	#)
	
	block_animations.process_block(blocking)
	
	mesh.set_instance_shader_parameter(
		"opacity",
		opacity
	)
	
	if animating_opacity: return
	
	if blocking:
		if entity.is_on_floor():
			locomotion_component.speed = walk_speed_while_blocking
		opacity = lerp(
			opacity,
			0.2,
			0.2
		)
	elif not anim.is_playing():
		opacity = lerp(
			opacity,
			0.0,
			0.2
		)


func blocked() -> void:
	if anim.current_animation != "blocked":
		print("BLOCKED")
		blocking = true
		anim.play("blocked")
	var particles: GPUParticles3D = _particles.duplicate()
	add_child(particles)
	particles.finished.connect(particles.queue_free)
	particles.restart()
