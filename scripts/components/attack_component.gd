class_name AttackComponent
extends Node3D

signal can_rotate(flag: bool)
signal can_move(flag: bool)

@export var character: PlayerAnimations
@export var movement_component: MovementComponent
@export var attack_level = 1
@export var can_attack = true

var _can_attack_again: bool


# Called when the node enters the scene tree for the first time.
func _ready():
	character.attack_animations.secondary_movement.connect(_receive_movement)
	character.attack_animations.attacking_finished.connect(_receive_attacking_finished)
	character.attack_animations.can_attack_again.connect(_receive_can_attack_again)
	character.attack_animations.can_rotate.connect(_receive_rotation)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("attack"):
		_attack()


func _attack():
	if can_attack:
		
		if _can_attack_again and  attack_level < 4:
			attack_level += 1
		else:
			attack_level = 1
				
		can_attack = false
		can_move.emit(false)
		character.attack_animations.attack(attack_level)
	
		
func _receive_can_attack_again(flag: bool):
	can_attack = true
	_can_attack_again = flag
	
	
func _receive_attacking_finished():
	can_move.emit(true)
	can_attack = true


func _receive_rotation(flag: bool):
	can_rotate.emit(flag)


func _receive_movement():
	match attack_level:
		1: 
			movement_component.set_secondary_movement(0.3, 1.2)
		2:
			movement_component.set_secondary_movement(0.3, 1.2)
		3:
			movement_component.set_secondary_movement(1.2, 0.2)
		4:
			movement_component.set_secondary_movement(-0.8, 0.2)
		
