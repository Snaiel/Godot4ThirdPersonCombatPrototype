class_name DeathScreen
extends Control


var _show_message: bool = false
var _fade_to_black: bool = false

@onready var _death_message: Control = $DeathMessage
@onready var _fade: TextureRect = $Fade


func _physics_process(_delta):
	
	if _show_message:
		_death_message.modulate.a = lerp(
			_death_message.modulate.a,
			1.0,
			0.1
		)
	else:
		_death_message.modulate.a = lerp(
			_death_message.modulate.a,
			0.0,
			0.1
		)
	
	if _fade_to_black:
		_fade.self_modulate.a = lerp(
			_fade.self_modulate.a,
			1.0,
			0.05
		)
	else:
		_fade.self_modulate.a = lerp(
			_fade.self_modulate.a,
			0.0,
			0.05
		)


func play_death_screen() -> void:
	var timer: SceneTreeTimer
	
	visible = true
	
	timer = get_tree().create_timer(2)
	timer.timeout.connect(
		func():
			_show_message = true
	)
	
	await timer.timeout
	timer = get_tree().create_timer(3)
	timer.timeout.connect(
		func():
			_show_message = false
	)
	
	await timer.timeout
	timer = get_tree().create_timer(2)
	timer.timeout.connect(
		func():
			_fade_to_black = true
	)
