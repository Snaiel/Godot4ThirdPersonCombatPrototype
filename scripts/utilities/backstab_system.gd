class_name BackstabSystem
extends Node3D

signal current_victim(victim: BackstabComponent)

var backstab_victim: BackstabComponent
var _current_dist_to_player: float = 10


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.backstab_system = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	if not backstab_victim:
		current_victim.emit(null)
		return
	
	_current_dist_to_player = backstab_victim\
		.entity\
		.global_position\
		.distance_to(Globals.player.global_position)


func set_backstab_victim(victim: BackstabComponent, dist: float) -> void:
#	if backstab_victim: prints(victim.get_parent().name, backstab_victim.get_parent().name, dist, _current_dist_to_player)
	if victim == backstab_victim:
		return
	
	if dist > _current_dist_to_player:
		return
		
	backstab_victim = victim
	_current_dist_to_player = dist
	
	current_victim.emit(victim)

func clear_backstab_victim(victim: BackstabComponent) -> void:
	if victim == backstab_victim:
		backstab_victim = null
