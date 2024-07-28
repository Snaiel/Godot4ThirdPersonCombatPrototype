@tool

class_name ShieldComponent
extends Node3D


@export var debug: bool = false
@export var entity: CharacterBody3D
@export var locomotion_component: LocomotionComponent

# used for the Globals.resources key
@export var animation_resource_key: String = "ShieldAnimation"

@export_category("Blocking")
@export var walk_speed_while_blocking: float = 0.8
@export var block_particles_scene: PackedScene = preload(
	"res://scenes/particles/BlockParticles.tscn"
)

@export_category("Shader")
@export var color: Color = Color.WHITE:
	set(value):
		if value == color: return
		color = value
		if not mesh: return
		_update_shield_color(color)
		
@export_range(0, 1.0) var default_opacity: float = 0.2:
	set(value):
		if value == default_opacity: return
		default_opacity = value
		if not mesh: return
		_update_shield_opacity(default_opacity)

var opacity: float = 0.0:
	set(value):
		if value == opacity: return
		opacity = value
		if not mesh: return
		_update_shield_opacity(opacity)
		
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
	
	_update_shield_opacity(0.0)
	
	animation_player.active = false
	animation_player.animation_finished.connect(
		func(_anim_name: String):
			animation_player.active = false
			_update_shield_color(color)
	)
	
	var _duplicate_animation = func(animation_name: StringName) -> Animation:
		var animation = animation_player.get_animation(animation_name)
		animation = animation.duplicate()
		_animation_library.remove_animation(animation_name)
		_animation_library.add_animation(animation_name, animation)
		return animation
	
	if Globals.resources.has(animation_resource_key):
		_animation_library = Globals.resources[animation_resource_key]
		animation_player.remove_animation_library(&"")
		animation_player.add_animation_library(&"", _animation_library)
	else:
		_animation_library = animation_player.get_animation_library(&"")
		_animation_library = _animation_library.duplicate()
		
		animation_player.remove_animation_library(&"")
		animation_player.add_animation_library(&"", _animation_library)
		
		_duplicate_animation.call(&"RESET").track_set_key_value(0, 0, color)
		_duplicate_animation.call(&"parried").track_set_key_value(1, 0, color)
		var blocked_anim = _duplicate_animation.call(&"blocked")
		blocked_anim.track_set_key_value(1, 0, color)
		blocked_anim.track_set_key_value(1, 3, color)
		
		Globals.resources[animation_resource_key] = _animation_library


func _physics_process(_delta: float) -> void:
	
	if Engine.is_editor_hint(): return
	
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


func play_animation(anim_name: StringName) -> void:
	animation_player.active = true
	animation_player.play(anim_name)


func blocked() -> void:
	if animation_player.current_animation != "blocked":
		print("BLOCKED")
		blocking = true
		play_animation(&"blocked")
	var particles: GPUParticles3D = _particles.duplicate()
	add_child(particles)
	particles.finished.connect(particles.queue_free)
	particles.restart()


func _update_shield_color(_color: Color) -> void:
	mesh.get_surface_override_material(0).set(
		"shader_parameter/emission_color",
		_color
	)


func _update_shield_opacity(_opacity: float) -> void:
	mesh.set_instance_shader_parameter(
		"opacity",
		_opacity
	)
