class_name HitboxComponent
extends Area3D


signal damage_source_hit(source: DamageSource)

@export var debug: bool = false
@export var entity: CharacterBody3D
@export var enabled: bool = true
@export var groups: Array[String]

var _damage_sources_in_hitbox: Array[DamageSource] = []

# DamageSource as key, damage_source.instance as value
var _successful_hits: Dictionary

@onready var dizzy_system: DizzySystem = Globals.dizzy_system


func _process(_delta: float) -> void:
#	if debug: print(_damage_sources_in_hitbox)
	
	if not enabled:
		return
	
	if len(_damage_sources_in_hitbox) == 0:
		return
	
	for damage_source in _damage_sources_in_hitbox:
		if not damage_source.can_damage:
			continue
		
		# dont detect the damage_source of the owner of this hitbox
		if damage_source.entity == entity:
			continue
		
		# ignore entities not in the specified groups
		var damage_source_entity_in_groups: bool = false
		for group in groups:
			if damage_source_entity_in_groups:
				break
			elif damage_source.entity.is_in_group(group):
				damage_source_entity_in_groups = true
		
		if not damage_source_entity_in_groups:
			continue
		
		# this damage_source has already successfully gotten a hit in
		# and so this subsequent detection should be ignored.
		if _successful_hits.has(damage_source) and \
		damage_source.instance == _successful_hits[damage_source]:
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
		damage_source.entity == Globals.player:
			continue
		
		prints("HIT", entity, damage_source, damage_source.instance)
		
		_successful_hits[damage_source] = damage_source.instance
		print(_successful_hits)
		
		damage_source_hit.emit(damage_source)
		_damage_sources_in_hitbox.erase(damage_source)
		if damage_source.hit_considered():
			_successful_hits.erase(damage_source)


func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("damage_source") and area.get_parent() not in _damage_sources_in_hitbox:
		var damage_source: DamageSource = area.get_parent()
		_damage_sources_in_hitbox.append(damage_source)


func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("damage_source"):
		var damage_source: DamageSource = area.get_parent()
		if damage_source in _damage_sources_in_hitbox:
			_damage_sources_in_hitbox.erase(damage_source)
