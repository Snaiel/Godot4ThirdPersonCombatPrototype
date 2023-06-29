extends Node3D

@export var cam_normal: Camera3D
@export var cam_fade: Camera3D
@export var player: Player
@export var fade_viewport: SubViewport
@export var fade_plane: MeshInstance3D

@export_category("Fade Settings")
@export var fade_distance = 2
@export var fade_offset = 0.6
@export var fade_cooldown = 0.5

var _mat: ShaderMaterial
var _player_transparent = false

func _ready():
	_mat = fade_plane.get_active_material(0) 
	_mat.set_shader_parameter("texture_albedo", fade_viewport.get_texture())


func _physics_process(_delta):
	cam_fade.global_transform = cam_normal.global_transform
	
	var dist = player.global_position.distance_to(cam_normal.global_position)
	var alpha = smoothstep(0.0, fade_distance, dist - fade_offset)
	
	if dist - fade_offset < fade_distance:
		if not _player_transparent:
			cam_normal.cull_mask = 1
			cam_fade.cull_mask = 2
			_player_transparent = true
	elif _player_transparent:
		cam_normal.cull_mask = 3
		cam_fade.cull_mask = 0		
		_player_transparent = false
	
	_mat.set_shader_parameter("alpha", alpha)	
