class_name AttackComponent
extends Node3D

signal can_rotate(flag: bool)
signal can_move(flag: bool)

@export var attack_animations: AttackAnimations
@export var movement_component: MovementComponent
@export var weapon: Sword
@export var attack_level = 1
@export var can_attack = true

var attacking = false
var can_stop_attack: bool = true

var _can_attack_again: bool = false
var _attack_interrupted: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	attack_animations.secondary_movement.connect(_receive_movement)
	attack_animations.can_damage.connect(_receive_can_damage)	
	attack_animations.attacking_finished.connect(_receive_attacking_finished)
	attack_animations.can_attack_again.connect(_receive_can_attack_again)
	attack_animations.can_rotate.connect(_receive_rotation)
	

func attack():
	if can_attack:
		attacking = true
		_attack_interrupted = false
		
		if _can_attack_again and attack_level < 4:
			attack_level += 1
		else:
			attack_level = 1
				
		can_attack = false
		
		can_rotate.emit(true)
		can_move.emit(false)
		attack_animations.attack(attack_level)
	
	
func stop_attacking() -> bool:
	if can_stop_attack:
		if attacking:
			_attack_interrupted = true
		can_move.emit(true)
		attacking = false
		attack_level = 1
		_can_attack_again = false
		attack_animations.stop_attacking()
	return not attacking
		
		
func _receive_can_attack_again(flag: bool):
	can_attack = true
	if not _attack_interrupted:
		_can_attack_again = flag
	
	
func _receive_attacking_finished():
	can_attack = true
	can_stop_attack = true
	stop_attacking()


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
		
		
func _receive_can_damage(can_damage: bool):
	can_stop_attack = false
	if not _attack_interrupted:
		weapon.can_damage = can_damage
