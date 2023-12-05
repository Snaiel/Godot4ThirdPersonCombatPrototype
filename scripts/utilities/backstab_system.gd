class_name BackstabSystem
extends Node3D


signal current_victim(victim: BackstabComponent)

var backstab_victim: BackstabComponent
var attack_component: AttackComponent

var _current_dist_to_player: float = 10
var _can_switch_victim: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.backstab_system = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	
	if backstab_victim and not backstab_victim.health_component.is_alive():
		backstab_victim = null
		_can_switch_victim = false
		var timer: SceneTreeTimer = get_tree().create_timer(1.0)
		timer.timeout.connect(func(): _can_switch_victim = true)
	
	if not backstab_victim:
		current_victim.emit(null)
		_current_dist_to_player = 10
		return
	
	_current_dist_to_player = backstab_victim\
		.entity\
		.global_position\
		.distance_to(Globals.player.global_position)


func set_backstab_victim(victim: BackstabComponent, dist: float) -> void:
#	if backstab_victim: prints(victim.get_parent().name, backstab_victim.get_parent().name, dist, _current_dist_to_player)
	
	if not backstab_victim and attack_component.attacking:
		return
	
	if not victim.health_component.is_alive():
		return
	
	if victim == backstab_victim:
		return
	
	if dist > _current_dist_to_player - 0.02:
		return
	
	if not _can_switch_victim:
		return
	
	backstab_victim = victim
	_current_dist_to_player = dist
	
	current_victim.emit(victim)

func clear_backstab_victim(victim: BackstabComponent) -> void:
	if victim == backstab_victim:
		backstab_victim = null
