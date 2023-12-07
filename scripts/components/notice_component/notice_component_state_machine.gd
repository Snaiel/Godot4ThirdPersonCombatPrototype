class_name NoticeComponentStateMachine
extends StateMachine

@export var notice_component: NoticeComponent

var debug: bool = false

var notice_triangle: PackedScene
var notice_triangle_sprite: Sprite2D

var entity: CharacterBody3D
var player: Player
var camera: Camera3D

var angle_to_player: float
var distance_to_player: float


func _ready():
	super._ready()


func _physics_process(delta):
	if debug: print(current_state)
	current_state.debug = debug
	
	angle_to_player = rad_to_deg(
		Vector3.FORWARD.rotated(Vector3.UP, entity.global_rotation.y).angle_to(
			entity.global_position.direction_to(player.global_position)
		)
	)
	distance_to_player = entity.global_position.distance_to(
		player.global_position
	)
	
	if camera.is_position_in_frustum(notice_component.global_position):
		notice_triangle_sprite.position = camera.unproject_position(notice_component.global_position)
	
	super._physics_process(delta)
