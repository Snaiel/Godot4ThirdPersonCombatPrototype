class_name MusicSystem
extends Node


var idle_music: bool = true

var _counter: int = 0:
	set(value):
		_counter = value
		if _counter < 0:
			_counter = 0

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
