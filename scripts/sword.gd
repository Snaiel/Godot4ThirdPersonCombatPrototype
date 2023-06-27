class_name Sword
extends StaticBody3D

@export var damage = 10
@export var knockback = 2
@export var can_impact = false

@onready var _animation_player = $AnimationPlayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("attack"):
		_animation_player.play("Strike")

func toggle_weapon_impact():
	can_impact = not can_impact
