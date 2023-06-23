class_name LockOnSystem
extends Node3D

signal lock_on(enemy: Enemy)

@export var enemy: Enemy = null
@export var potential_target: Enemy = null

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.lock_on_system = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("lock_on"):
		if enemy:
			enemy = null
		else:
			enemy = potential_target
		lock_on.emit(enemy)
