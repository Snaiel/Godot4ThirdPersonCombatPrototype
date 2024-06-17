@tool

class_name WaitBlock
extends SequenceComposite

@export var wait_id: int
@export var generate_wait_id: bool
@export var wait_time: float

@export var wait_leaf: Wait
@export var reset_wait: ResetWait


func _enter_tree():
	if not Engine.is_editor_hint():
		wait_leaf.time = wait_time
		wait_leaf.wait_id = wait_id
		reset_wait.wait_id = wait_id


func _process(_delta):
	if Engine.is_editor_hint() and generate_wait_id:
		generate_wait_id = false
		var rng = RandomNumberGenerator.new()
		wait_id = rng.randi_range(10000000, 99999999)
