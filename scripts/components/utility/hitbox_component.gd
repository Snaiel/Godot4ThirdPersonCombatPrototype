class_name HitboxComponent
extends Area3D


signal weapon_hit(weapon: Weapon)

@export var debug: bool = false
@export var entity: CharacterBody3D
@export var enabled: bool = true
@export var groups: Array[String]

var _weapons_in_hitbox: Array[Weapon] = []

# Weapon as key, wepaon.attack_component.instance as value
var _successful_hits: Dictionary

@onready var dizzy_system: DizzySystem = Globals.dizzy_system


func _process(_delta: float) -> void:
#	if debug: print(_weapons_in_hitbox)
	
	if not enabled:
		return
	
	if len(_weapons_in_hitbox) == 0:
		return
	
	for weapon in _weapons_in_hitbox:
		if not weapon.can_damage:
			continue
		
		# dont detect the weapon of the owner of this hitbox
		if weapon.entity == entity:
			continue
		
		# ignore entities not in the specified groups
		var weapon_entity_in_groups: bool = false
		for group in groups:
			if weapon_entity_in_groups:
				break
			elif weapon.entity.is_in_group(group):
				weapon_entity_in_groups = true
		
		if not weapon_entity_in_groups:
			continue
		
		print(_successful_hits)
		
		# this weapon has already successfully gotten a hit in
		# and so this subsequent detection should be ignored.
		if _successful_hits.has(weapon) and \
		weapon.attack_component.instance == _successful_hits[weapon]:
			continue
		
		# if an entity is being finished while it is
		# dizzy, do not register the hit if the
		# victim is not this entity 
		if dizzy_system.victim_being_killed and \
		(
			(
				dizzy_system.dizzy_victim != null and \
				dizzy_system.dizzy_victim.entity != entity
			) or \
			(
				dizzy_system.saved_victim != null and \
				dizzy_system.saved_victim.entity != entity
			)
		) and \
		weapon.entity == Globals.player:
			continue
		
		prints("HIT", entity, weapon, weapon.attack_component.instance)
		
		_successful_hits[weapon] = weapon.attack_component.instance
		print(_successful_hits)
		
		weapon_hit.emit(weapon)
		_weapons_in_hitbox.erase(weapon)


func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("weapon") and area.get_parent() not in _weapons_in_hitbox:
		var weapon: Weapon = area.get_parent()
		_weapons_in_hitbox.append(weapon)


func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("weapon"):
		var weapon: Weapon = area.get_parent()
		if weapon in _weapons_in_hitbox:
			_weapons_in_hitbox.erase(weapon)
