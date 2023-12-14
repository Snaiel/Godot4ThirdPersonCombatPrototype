class_name ParryComponent
extends Node3D


@export var block_component: BlockComponent

var in_parry_window: bool = false
var parry_interval: float = 0.2

var _parry_timer: Timer


func _ready() -> void:
	_parry_timer = Timer.new()
	_parry_timer.wait_time = parry_interval
	_parry_timer.autostart = false
	_parry_timer.one_shot = true
	_parry_timer.timeout.connect(
		func():
			in_parry_window = false
			print("parry window closed!")
	)
	add_child(_parry_timer)


func _physics_process(_delta) -> void:
	pass


func parry() -> void:
	if in_parry_window:
		return
	
	in_parry_window = true
	_parry_timer.start()
	print("parry window open!")
