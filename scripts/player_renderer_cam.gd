extends Camera3D

@export var cam: Camera3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_transform = cam.global_transform
