class_name CheckpointInterface
extends Control


signal perform_recovery


@export var show_menu: bool = false

var fade_out: bool = false

@onready var menu: Control = $Menu
@onready var recover_button: Button = $Menu/Buttons/Recover
@onready var return_button: Button = $Menu/Buttons/Return
@onready var fade_texture: TextureRect = $Fade

@onready var checkpoint_system: CheckpointSystem = Globals.checkpoint_system


func _ready():
	visible = false
	menu.modulate.a = 0
	
	recover_button.pressed.connect(_recover)


func _physics_process(_delta):
	
	if show_menu:
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


func _recover() -> void:
	show_menu = false
	
	checkpoint_system.closest_checkpoint.play_recovery_particles()
	
	var timer: SceneTreeTimer
	timer = get_tree().create_timer(1)
	timer.timeout.connect(
		func():
			fade_out = true
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
			show_menu = true
	)
