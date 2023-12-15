class_name WellbeingComponent
extends Node3D


@export_category("Configuration")
@export var lock_on_component: LockOnComponent
@export var backstab_component: BackstabComponent
@export var health_component: HealthComponent

@export_category("Wellbeing Widget")
@export var wellbeing_widget_scene: PackedScene

var _well_being_widget: WellbeingWidget
var _health_bar: NPCHealthBar

var _visible: bool = false

@onready var _camera: Camera3D = Globals.camera_controller.cam
@onready var _lock_on_system: LockOnSystem = Globals.lock_on_system


func _ready():
	_well_being_widget = wellbeing_widget_scene.instantiate()
	Globals.user_interface.wellbeing_widgets.add_child(_well_being_widget)
	_health_bar = _well_being_widget.health_bar
	_health_bar.default_health = health_component.max_health
	
	health_component.took_damage.connect(
		func():
			_visible = true
			_health_bar.show_health_bar(health_component.get_health())
	)


func _process(_delta):
	_health_bar.process_health(health_component.get_health())
	
	if _lock_on_system.target == lock_on_component or\
		_health_bar.health_bar_visible:
		_visible = true
	else:
		_visible = false
		
	if not _camera.is_position_in_frustum(global_position):
		_visible = false
	
	_well_being_widget.visible = _visible
	
	_well_being_widget.position = _camera.unproject_position(global_position)
