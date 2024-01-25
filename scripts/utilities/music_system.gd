class_name MusicSystem
extends Node


var idle_music: bool = true

var _counter: int = 0:
	set(value):
		_counter = value
		if _counter < 0:
			_counter = 0

@onready var anim: AnimationPlayer = $AnimationPlayer


#func _physics_process(_delta):
#	print(_counter)


func fade_to_active() -> void:
	if not idle_music:
		return
	
	idle_music = false
	anim.play("FadeToActive")
	_counter += 1


func fade_to_idle() -> void:
	if idle_music:
		return
	
	_counter -= 1
	
	if _counter != 0:
		return
	
	idle_music = true
	anim.play("FadeToIdle")
