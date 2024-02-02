class_name CheckpointInterface
extends Control


signal perform_recovery
signal exit_checkpoint


var fade_out: bool = false

var _show_menu: bool = false
var _prev_mouse_mode: int

@onready var menu: Control = $Menu
@onready var recover_button: Button = $Menu/Buttons/Recover
@onready var return_button: Button = $Menu/Buttons/Return
@onready var fade_texture: TextureRect = $Fade

@onready var music_system: MusicSystem = Globals.music_system


func _ready():
	visible = false
	menu.modulate.a = 0
	
	recover_button.pressed.connect(_recover)
	return_button.pressed.connect(
		func():
			exit_checkpoint.emit()
	)


func _physics_process(_delta):
	
	if _show_menu:
		menu.modulate.a = lerp(
			menu.modulate.a,
			1.0,
			0.1
		)
	else:
		menu.modulate.a = lerp(
			menu.modulate.a,
			0.0,
			0.1
		)
	
	if fade_out:
		fade_texture.self_modulate.a = lerp(
			fade_texture.self_modulate.a,
			1.0,
			0.03
		)
	else:
		fade_texture.self_modulate.a = lerp(
			fade_texture.self_modulate.a,
			0.0,
			0.03
		)
	
	if Input.is_action_just_pressed("ui_cancel") and _show_menu:
		exit_checkpoint.emit()


func _input(event: InputEvent):
	if event is InputEventMouseMotion and _show_menu:
		_prev_mouse_mode = Input.mouse_mode
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if _prev_mouse_mode != Input.MOUSE_MODE_VISIBLE:
			warp_mouse(
				recover_button.global_position + (recover_button.size / 2)
			)


func show_menu() -> void:
	visible = true
	_show_menu = true
	recover_button.grab_focus()


func hide_menu() -> void:
	_show_menu = false


func _recover() -> void:
	_show_menu = false
	
	Globals.checkpoint_system.current_checkpoint.play_recovery_particles()
	
	var timer: SceneTreeTimer
	timer = get_tree().create_timer(1)
	timer.timeout.connect(
		func():
			fade_out = true
			if music_system.active_song.playing:
				music_system.force_fade_to_idle()
	)
	
	await timer.timeout
	timer = get_tree().create_timer(2)
	timer.timeout.connect(
		func():
			perform_recovery.emit()
	)
	
	await timer.timeout
	timer = get_tree().create_timer(1)
	timer.timeout.connect(
		func():
			fade_out = false
	)

	await timer.timeout
	timer = get_tree().create_timer(1)
	timer.timeout.connect(
		func():
			_show_menu = true
	)
