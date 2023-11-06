class_name Enemy
extends CharacterBody3D

signal death(enemy)

@export var target: Node3D
@export var debug: bool = false
@export var friction: float = 0.05

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _blackboard: Blackboard = $Blackboard
@onready var _rotation_component: RotationComponent = $RotationComponent
@onready var _agent: NavigationAgent3D = $NavigationAgent3D

func _ready() -> void:
	target = Globals.player
	_rotation_component.target = target

func _physics_process(_delta: float) -> void:
	_agent.target_position = target.global_position

	var target_dist: float = global_position.distance_to(target.global_position)
	var target_dir: Vector3 = global_position.direction_to(target.global_position)
	var target_dir_angle: float = target_dir.angle_to(Vector3.FORWARD.rotated(Vector3.UP, global_rotation.y))

	_blackboard.set_value("target", target)
	_blackboard.set_value("target_dist", target_dist)
	_blackboard.set_value("target_dir", target_dir)
	_blackboard.set_value("target_dir_angle", target_dir_angle)

	if debug:
		_rotation_component.debug = debug
#		print(_rotation_component.look_at_target)
#		print(_blackboard.get_value("input_direction", Vector3.ZERO))
#		print(_rotation_component.move_direction, " ", _movement_component.desired_velocity)

	_rotation_component.look_at_target = _blackboard.get_value("look_at_target", false)


func get_hit(knockback: float) -> void:
	var player = Globals.player
	velocity = player.position.direction_to(position) * knockback


func _on_entity_hitbox_weapon_hit(weapon: Sword) -> void:
	get_hit(weapon.knockback)


func _on_health_component_zero_health() -> void:
	death.emit(self)
	queue_free()
