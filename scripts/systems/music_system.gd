class_name MusicSystem
extends Node


@export var enabled: bool = true

var idle_music: bool = true

var _counter: int = 0:
	set(value):
		_counter = value
		if _counter < 0:
			_counter = 0

@onready var idle_song: AudioStreamPlayer = $IdleBackgroundMusic
@onready var active_song: AudioStreamPlayer = $ActiveBackgroundMusic
@onready var anim: AnimationPlayer = $AnimationPlayer


func _ready():
	if enabled: idle_song.play()
	
	anim.active = false
	anim.animation_finished.connect(
		func(_anim_name: String): anim.active = false
	)


func play_animation(anim_name: StringName) -> void:
	anim.active = true
	anim.play(anim_name)


func fade_to_active() -> void:
	_counter += 1
	
	if not enabled: return
	if not idle_music: return
	
	idle_music = false
	play_animation(&"FadeToActive")


func fade_to_idle() -> void:
	_counter -= 1
	
	if not enabled: return
	if idle_music: return
	if _counter != 0: return
	
	force_fade_to_idle()


func force_fade_to_idle() -> void:
	if not enabled: return
	idle_music = true
	play_animation(&"FadeToIdle")


func fade_out() -> void:
	if not enabled: return
	
	if idle_music:
		play_animation(&"IdleFadeOut")
	else:
		play_animation(&"ActiveFadeOut")
	
	idle_music = true
	_counter = 0


func reset() -> void:
	play_animation(&"RESET")
