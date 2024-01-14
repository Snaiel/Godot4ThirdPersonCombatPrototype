class_name DeathScreen
extends Control


signal respawn
signal stand_up


var _show_message: bool = false
var _fade_to_black: bool = false

var _respawning: bool = false

@onready var _death_message: Control = $DeathMessage
@onready var _fade: TextureRect = $Fade

@onready var _checkpoint_system: CheckpointSystem = Globals.checkpoint_system


func _ready():
	visible = false


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
		_fade.self_modulate.a = move_toward(
			_fade.self_modulate.a,
			1.0,
			0.02
		)
	else:
		_fade.self_modulate.a = move_toward(
			_fade.self_modulate.a,
			0.0,
			0.02
		)
	
	if is_zero_approx(_fade.self_modulate.a) and _respawning:
		visible = false
		_respawning = false


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
	timer = get_tree().create_timer(1)
	timer.timeout.connect(
		func():
			_fade_to_black = true
	)
	
	await timer.timeout
	timer = get_tree().create_timer(2)
	timer.timeout.connect(
		func():
			respawn.emit()
			_checkpoint_system.recover_after_death()
	)
	
	await timer.timeout
	timer = get_tree().create_timer(1)
	timer.timeout.connect(
		func():
			_fade_to_black = false
			_respawning = true
	)
	
	await timer.timeout
	timer = get_tree().create_timer(0.5)
	timer.timeout.connect(
		func():
			stand_up.emit()
	)
