extends Node3D

@export var cam_controller: CameraController
@export var cam_normal: Camera3D
@export var cam_fade: Camera3D
@export var fade_viewport: SubViewport
@export var fade_plane: MeshInstance3D

@export_category("Fade Settings")
@export var fade_distance = 1.3
@export var fade_offset = 0.4
@export var fade_cooldown = 0.5

@onready var _player = get_owner().player

var _mat: ShaderMaterial
var _player_transparent = false
var _dist
var _alpha: float = 1
var _would_be_alpha: float

func _ready():
	_mat = fade_plane.get_active_material(0) 
	_mat.set_shader_parameter("texture_albedo", fade_viewport.get_texture())
	
	cam_normal.cull_mask = 1
	cam_fade.cull_mask = 2
	_player_transparent = true

func _physics_process(_delta):
	cam_fade.global_transform = cam_normal.global_transform
	
	_dist = _player.global_position.distance_to(cam_normal.global_position)
	_would_be_alpha = smoothstep(fade_offset, fade_distance, _dist)
	
	if cam_controller.rotation_degrees.x > -20:
		_alpha = lerp(_alpha, _would_be_alpha, 0.1)
	else:
		_alpha = 1
	
	
	if _dist < fade_distance and cam_controller.rotation_degrees.x > -20:
		if not _player_transparent:
			cam_normal.cull_mask = 1
			cam_fade.cull_mask = 2
			_player_transparent = true
	elif _player_transparent:
		cam_normal.cull_mask = 3
		cam_fade.cull_mask = 0		
		_player_transparent = false
	
	_mat.set_shader_parameter("alpha", _alpha)	
