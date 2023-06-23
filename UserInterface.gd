extends Control

@export var locked_on_enemy: Enemy

@onready var _lock_on_texture = $LockOn

# Called when the node enters the scene tree for the first time.
func _ready():
	_lock_on_texture.visible = false

func _process(_delta):
	if locked_on_enemy:
		var pos = Globals.camera_controller.get_lock_on_position(locked_on_enemy)
		var lock_on_pos = Vector2(pos.x - _lock_on_texture.size.x / 2, pos.y - _lock_on_texture.size.y / 2)
		_lock_on_texture.position = lock_on_pos

func _on_player_lock_on(enemy: Enemy):
	locked_on_enemy = enemy
	_lock_on_texture.visible = enemy != null
