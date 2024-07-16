class_name MeleeComponent
extends Node


signal can_rotate(flag: bool)


@export var debug: bool = false
@export var melee_animations: MeleeAnimations
@export var locomotion_component: LocomotionComponent
@export var weapons: Dictionary
@export var can_attack: bool = true

var attacking: bool = false

# this is pretty much read only. changing this wont affect
# the attack level when attack() is called. you must supply
# the desired level as a parameter in the attack() function.
var attack_level: int = 0

var _can_stop_attack: bool = true
var _can_attack_again: bool = false
var _attack_interrupted: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	melee_animations.secondary_movement.connect(_receive_movement)
	melee_animations.damage_attributes.connect(_receive_damage_attributes)
	melee_animations.can_rotate.connect(_receive_rotation)
	melee_animations.can_damage.connect(_receive_can_damage)
	melee_animations.can_attack_again.connect(_receive_can_attack_again)
	melee_animations.can_play_animation.connect(_receive_can_play_animation)
	melee_animations.attacking_finished.connect(_receive_attacking_finished)


func _process(_delta):
	if debug: print(attacking)


func attack(
		level: int = 0,
		override_can_play: bool = false,
		can_stop: bool = true
	) -> void:
	
	increment_weapon_instance()
	
	if not can_attack:
		return
		
	attacking = true
	_can_stop_attack = can_stop
	_attack_interrupted = false
	
	attack_level = level
	
	can_attack = false
	can_rotate.emit(true)
	melee_animations.attack(attack_level, override_can_play)


func increment_weapon_instance() -> void:
	for i in weapons.values():
		var weapon: DamageSource = get_node(i)
		weapon.instance += 1


func disable_attack_interrupted() -> void:
	_attack_interrupted = false


## request to stop attacking (for example, when blocking)
func stop_attacking() -> bool:
	if _can_stop_attack:
		interrupt_attack()
	return not attacking


func set_can_damage_of_all_weapons(flag: bool) -> void:
	for i in weapons.values():
		var weapon: DamageSource = get_node(i)
		weapon.can_damage = flag


func interrupt_attack() -> void:
	if attacking:
		_attack_interrupted = true
	
	attacking = false
	attack_level = 0
	
	can_attack = true
	_can_attack_again = false
	
	melee_animations.stop_attacking()
	
	set_can_damage_of_all_weapons(false)


func _receive_rotation(flag: bool) -> void:
	can_rotate.emit(flag)
	


func _receive_movement(melee_attack: MeleeAttack) -> void:
	_can_stop_attack = false
	
	if _attack_interrupted:
		return
	
	locomotion_component.set_secondary_movement(
		melee_attack.secondary_movement
	)


func _receive_damage_attributes(attributes: DamageAttributes) -> void:
	for weapon_path in weapons.values():
		var weapon: DamageSource = get_node(weapon_path)
		weapon.damage_attributes = attributes


func _receive_can_damage(can_damage: bool, weapon_names: Array[StringName]) -> void:
	if _attack_interrupted: return
	
	prints(can_damage, weapon_names)
	
	if weapon_names.size() == 0:
		set_can_damage_of_all_weapons(can_damage)
		return
	
	for weapon_name in weapon_names:
		prints(weapon_name, weapons)
		if not weapons.has(weapon_name): continue
		var weapon: DamageSource = get_node(weapons[weapon_name])
		weapon.can_damage = can_damage
		prints(weapon, weapon.can_damage)


func _receive_can_attack_again(can_attack_again: bool) -> void:
	can_attack = true
	if not _attack_interrupted:
		_can_attack_again = can_attack_again


func _receive_can_play_animation() -> void:
	_can_stop_attack = true


func _receive_attacking_finished() -> void:
	can_attack = true
	stop_attacking()
