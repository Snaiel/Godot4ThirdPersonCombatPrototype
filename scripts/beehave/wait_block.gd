extends SequenceComposite

@export var wait_id: int
@export var wait_time: float

@export var wait_leaf: Wait
@export var reset_wait: ResetWait


func _enter_tree():
	wait_leaf.time = wait_time
	wait_leaf.wait_id = wait_id
	reset_wait.wait_id = wait_id
