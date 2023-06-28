extends MeshInstance3D

@export var viewport: SubViewport
@export var cam: Camera3D
@export var player: Player

@export_category("Fade Settings")
@export var fade_distance = 2
@export var fade_offset = 0.6

var _mat: ShaderMaterial

func _ready():
	_mat = get_active_material(0) 
	_mat.set_shader_parameter("texture_albedo", viewport.get_texture())

func _process(_delta):
	var dist = player.global_position.distance_to(cam.global_position)
	var alpha = smoothstep(0.0, fade_distance, dist - fade_offset)
	_mat.set_shader_parameter("alpha", alpha)	
