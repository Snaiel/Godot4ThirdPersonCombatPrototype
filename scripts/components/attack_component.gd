class_name AttackComponent
extends Node3D

signal attacking(active: bool)
signal can_rotate(flag: bool)

@export var character: PlayerAnimations
@export var attack_level = 1
@export var can_attack = true
@export var can_attack_again = false

# Called when the node enters the scene tree for the first time.
func _ready():
	character.movement_animations.can_rotate.connect(_receive_rotation)
	character.attack_animations.attacking_finished.connect(_attacking_finished)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("attack"):
		_attack()

func _attack():
	var anim_tree = character.anim_tree
	anim_tree["parameters/Attacking/transition_request"] = "attacking"
	anim_tree["parameters/Inward Slash/Walk Forwards Trim/seek_request"] = 0.55
	attacking.emit(true)

func _attacking_finished():
	attacking.emit(false)

func _receive_rotation(flag: bool):
	can_rotate.emit(flag)
