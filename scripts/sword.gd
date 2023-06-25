class_name Sword
extends StaticBody3D

signal weapon_impact(damage: int, knockback: float)

@onready var _animation_player = $AnimationPlayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("attack"):
		_animation_player.play("Strike")

func register_weapon_impact():
	weapon_impact.emit(10, 5)
