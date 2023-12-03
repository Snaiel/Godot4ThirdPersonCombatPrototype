class_name BackstabSystem
extends Node3D


signal backstab_victim(victim: BackstabComponent)

var _backstab_victim: BackstabComponent
var _current_dist_to_player: float = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.backstab_system = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not _backstab_victim:
		backstab_victim.emit(null)
		return
	
	_current_dist_to_player = _backstab_victim\
		.entity\
		.global_position\
		.distance_to(Globals.player.global_position)


func set_backstab_victim(victim: BackstabComponent, dist: float) -> void:
#	if _backstab_victim: prints(victim.get_parent().name, _backstab_victim.get_parent().name, dist, _current_dist_to_player)
	if victim == _backstab_victim:
		return
	
	if dist > _current_dist_to_player:
		return
		
	_backstab_victim = victim
	_current_dist_to_player = dist
	
	backstab_victim.emit(victim)
	

func clear_backstab_victim(victim: BackstabComponent) -> void:
	if victim == _backstab_victim:
		_backstab_victim = null
