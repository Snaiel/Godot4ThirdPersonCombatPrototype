class_name MusicSystem
extends Node


var idle_music: bool = true

@onready var idle_song: AudioStreamPlayer = $IdleBackgroundMusic
@onready var active_song: AudioStreamPlayer = $ActiveBackgroundMusic
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready():
	Globals.player.aggro_enemy_counter_changed.connect(on_counter_changed)

func on_counter_changed(old_value, new_value):
	if new_value > 0:
		fade_to_active()
	else:
		fade_to_idle()

func fade_to_active() -> void:
	if not idle_music:
		return
	
	idle_music = false
	anim.play("FadeToActive")


func fade_to_idle() -> void:
	if idle_music:
		return
	
	force_fade_to_idle()


func force_fade_to_idle() -> void:
	idle_music = true
	anim.play("FadeToIdle")


func fade_out() -> void:
	if idle_music:
		anim.play("IdleFadeOut")
	else:
		anim.play("ActiveFadeOut")
	
	idle_music = true


func reset() -> void:
	anim.play("RESET")
