@tool

class_name ShieldComponent
extends Node3D


@export var debug: bool = false
@export var entity: CharacterBody3D
@export var locomotion_component: LocomotionComponent

@export_category("Blocking")
@export var block_animations: BlockAnimations
@export var walk_speed_while_blocking: float = 0.8
@export var block_particles_scene: PackedScene = preload(
	"res://scenes/particles/BlockParticles.tscn"
)

@export_category("Shader")
@export var color: Color = Color.WHITE
@export_range(0, 1.0) var default_opacity: float = 0.2

var opacity: float = 0.0
var animating_opacity: bool = false
var blocking: bool = false:
	set(value):
		if value == blocking: return
		blocking = value

var _particles: GPUParticles3D
var _animation_library: AnimationLibrary

@onready var mesh: MeshInstance3D = $Mesh
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var light: OmniLight3D = $Light


func _ready():
	_particles = block_particles_scene.instantiate()
	light.light_energy = 0
	
	opacity = 0
	
	_animation_library = animation_player.get_animation_library(&"")
	_animation_library = _animation_library.duplicate()
	animation_player.remove_animation_library(&"")
	animation_player.add_animation_library(&"", _animation_library)
	
	_duplicate_animation(&"RESET").track_set_key_value(0, 0, color)
	_duplicate_animation(&"parried").track_set_key_value(1, 0, color)
	var blocked_anim = _duplicate_animation(&"blocked")
	blocked_anim.track_set_key_value(1, 0, color)
	blocked_anim.track_set_key_value(1, 3, color)
	
	#prints(_animation_library, blocked_anim)


func _physics_process(_delta: float) -> void:
	
	mesh.get_surface_override_material(0).set(
		"shader_parameter/emission_color",
		color
	)
	
	mesh.set_instance_shader_parameter(
		"opacity",
		default_opacity
	)
	
	if Engine.is_editor_hint(): return
	
	mesh.set_instance_shader_parameter(
		"opacity",
		opacity
	)
	
	block_animations.process_block(blocking)

	if animating_opacity: return
	
	if blocking:
		if entity.is_on_floor():
			locomotion_component.speed = walk_speed_while_blocking
		opacity = lerp(
			opacity,
			default_opacity,
			0.2
		)
	elif not animation_player.is_playing():
		opacity = lerp(
			opacity,
			0.0,
			0.2
		)


func blocked() -> void:
	if animation_player.current_animation != "blocked":
		print("BLOCKED")
		blocking = true
		animation_player.play("blocked")
	var particles: GPUParticles3D = _particles.duplicate()
	add_child(particles)
	particles.finished.connect(particles.queue_free)
	particles.restart()


func _duplicate_animation(animation_name: StringName) -> Animation:
	var animation = animation_player.get_animation(animation_name)
	animation = animation.duplicate()
	_animation_library.remove_animation(animation_name)
	_animation_library.add_animation(animation_name, animation)
	return animation
