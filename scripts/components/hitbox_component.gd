class_name HitboxComponent
extends Area3D


signal weapon_hit(weapon: Sword)

@export var debug: bool = false
@export var entity: CharacterBody3D
@export var character: CharacterAnimations

var _weapons_in_hitbox: Array[Sword] = []


func _process(_delta: float) -> void:
#	if debug: print(_weapons_in_hitbox)
	
	if not _weapons_in_hitbox:
		return
		
	for weapon in _weapons_in_hitbox:
		if not weapon.can_damage:
			continue
			
		if weapon.get_entity() == entity:
			continue
			
		weapon_hit.emit(weapon)
		_weapons_in_hitbox.erase(weapon)
		_process_hit_reaction()


func _process_hit_reaction() -> void:
	if entity.velocity.length() > 0.05:
		character.anim_tree["parameters/Hit Reaction Moving/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	else:
		character.anim_tree["parameters/Hit Reaction Not Moving/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE


func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("weapon") and area.get_parent() not in _weapons_in_hitbox:
		var weapon: Sword = area.get_parent()
		_weapons_in_hitbox.append(weapon)


func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("weapon"):
		var weapon: Sword = area.get_parent()
		if weapon in _weapons_in_hitbox:
			_weapons_in_hitbox.erase(weapon)
