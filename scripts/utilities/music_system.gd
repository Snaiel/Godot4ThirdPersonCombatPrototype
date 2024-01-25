class_name MusicSystem
extends Node


var idle_music: bool = true

var _counter: int = 0:
	set(value):
		_counter = value
		if _counter < 0:
			_counter = 0

@onready var idle_song: AudioStreamPlayer = $IdleBackgroundMusic
@onready var active_song: AudioStreamPlayer = $ActiveBackgroundMusic
@onready var anim: AnimationPlayer = $AnimationPlayer


func fade_to_active() -> void:
	_counter += 1
	
	if not idle_music:
		return
	
	idle_music = false
	anim.play("FadeToActive")


func fade_to_idle() -> void:
	_counter -= 1
	
	if idle_music:
		return
	
	if _counter != 0:
		return
	
	idle_music = true
	anim.play("FadeToIdle")


func fade_out() -> void:
	if idle_music:
		anim.play("IdleFadeOut")
	else:
		anim.play("ActiveFadeOut")
	
	idle_music = true
	_counter = 0


func reset() -> void:
	anim.play("RESET")
