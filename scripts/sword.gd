extends Area3D

@onready var _animation_player = $AnimationPlayer

var _enemy_currently_inside = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("attack"):
		_animation_player.play("Strike")

func register_hit():
	if _enemy_currently_inside:
		print(_enemy_currently_inside)
		_enemy_currently_inside.get_hit()

func _on_body_entered(body):
	_enemy_currently_inside = body

func _on_body_exited(_body):
	_enemy_currently_inside = null
