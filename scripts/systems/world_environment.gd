extends WorldEnvironment


@export var enable_fog: bool = false

func _ready():
	environment.fog_enabled = enable_fog
	environment.volumetric_fog_enabled = enable_fog
