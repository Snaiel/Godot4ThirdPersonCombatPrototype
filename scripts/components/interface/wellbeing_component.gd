class_name WellbeingComponent
extends Node


@export var wellbeing_stats: WellbeingStats

@export_category("Configuration")
@export var debug: bool = false
@export var hud_info: Node3D

@export_category("Components")
@export var lock_on_component: LockOnComponent
@export var backstab_component: BackstabComponent
@export var health_component: HealthComponent
@export var instability_component: InstabilityComponent
@export var notice_component: NoticeComponent

@export_category("Wellbeing Widget")
@export var wellbeing_widget_scene: PackedScene

var _wellbeing_widget: WellbeingWidget
var _health_bar: NPCHealthBar
var _instability_bar: NPCInstabilityBar

var _default_health_bar_y_pos: float
var _health_bar_y_pos_instability_invisible: float = -4.0

var _visible: bool = false

@onready var _camera: Camera3D = Globals.camera_controller.cam
@onready var _lock_on_system: LockOnSystem = Globals.lock_on_system


func _ready():
	health_component.health = wellbeing_stats.initial_health
	health_component.max_health = wellbeing_stats.max_health
	instability_component.instability = wellbeing_stats.initial_instability
	instability_component.can_reduce_instability = wellbeing_stats\
		.can_reduce_instability
	
	_wellbeing_widget = wellbeing_widget_scene.instantiate()
	Globals.user_interface.hud.wellbeing_widgets.add_child(_wellbeing_widget)
	
	_health_bar = _wellbeing_widget.health_bar
	_health_bar.default_health = health_component.max_health
	_health_bar.current_health = health_component.health
	_health_bar.default_health = health_component.max_health
	_health_bar.setup()
	health_component.took_damage.connect(
		func():
			_visible = true
			_health_bar.show_health_bar()
	)
	_default_health_bar_y_pos = _health_bar.position.y
	
	_instability_bar = _wellbeing_widget.instability_bar
	_instability_bar.max_instability = instability_component.max_instability
	_instability_bar.current_instability = instability_component.instability
	instability_component.instability_increased.connect(
		func():
			_instability_bar.instability_increased(
				instability_component.instability
			)
	)


func _process(_delta):
	_health_bar.current_health = health_component.health
	_instability_bar.current_instability = instability_component.instability
	
#	if debug:
#		prints(
#			_lock_on_system.target == lock_on_component,
#			_health_bar.should_be_visible,
#			_instability_bar.should_be_visible
#		)
	
	# check whether to make the entire widget visible
	if _lock_on_system.target == lock_on_component or \
	_health_bar.should_be_visible or \
	_instability_bar.should_be_visible:
		
		_visible = true
		
		# check whether the instability bar should be visible
		if (_instability_bar.should_be_visible or \
		instability_component.instability > 0) and \
		health_component.health > 0:
			_instability_bar.visible = true
			_health_bar.position.y = _default_health_bar_y_pos
			notice_component.triangle_y_offset = -25
		else:
			_instability_bar.should_be_visible = false
			_instability_bar.visible = false
			_health_bar.position.y = _health_bar_y_pos_instability_invisible
			notice_component.triangle_y_offset = -15
	else:
		_visible = false
		notice_component.triangle_y_offset = -10
	
	if not _camera.is_position_in_frustum(hud_info.global_position):
		_visible = false
	
	_wellbeing_widget.visible = _visible
	
	_wellbeing_widget.position = _camera.unproject_position(
		hud_info.global_position
	)


func hide_wellbeing_widget() -> void:
	_wellbeing_widget.visible = false
