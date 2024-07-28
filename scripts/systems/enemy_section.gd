class_name EnemySection
extends Area3D


enum NodeOperation {ADD, REMOVE, NONE}

@onready var enemies: Node3D = $Enemies
@onready var patrols: Node3D

var queued_for_deletion: bool = false

var enemy_nodes: Array[Node]
var current_operation: NodeOperation = NodeOperation.NONE

var _time_gap: float = 0.2
var _timer: float


func _ready():
	patrols = get_node_or_null("Patrols")
	
	enemy_nodes = enemies.get_children()
	for child in enemy_nodes:
		enemies.remove_child(child)
	_set_patrols_enabled(false)
	
	body_entered.connect(func(_body: Node3D): _add_enemies())
	body_exited.connect(func(_body: Node3D): _remove_enemies())
	
	_timer = _time_gap


func _process(delta: float) -> void:
	if current_operation == NodeOperation.NONE: return
	
	_timer -= delta
	
	if _timer > 0: return
	
	if current_operation == NodeOperation.ADD:
		if len(enemy_nodes) > 0:
			enemies.add_child(enemy_nodes.pop_front())
		else:
			current_operation = NodeOperation.NONE
			Globals.checkpoint_system.set_node_owner_to_enemies(
				enemies, enemies
			)
	elif current_operation == NodeOperation.REMOVE:
		if enemies.get_child_count() > 0:
			var child = enemies.get_child(0)
			enemies.remove_child(child)
		else:
			current_operation = NodeOperation.NONE
	
	_timer = _time_gap


func _notification(what: int) -> void:
	if what != NOTIFICATION_PREDELETE: return
	prints("Unregistering beehave trees in", self)
	for node in enemies.get_children():
		var enemy: Enemy = node
		BeehaveDebuggerMessages.unregister_tree(
			enemy.beehave_tree.get_instance_id()
		)


func free_enemies() -> void:
	queued_for_deletion = true
	for enemy in enemy_nodes:
		enemy.queue_free()


func _add_enemies() -> void:
	if queued_for_deletion: return
	print("Player entered enemy section: " + name)
	current_operation = NodeOperation.ADD
	_timer = _time_gap
	_set_patrols_enabled(true)


func _remove_enemies() -> void:
	if queued_for_deletion: return
	print("Player left enemy section: " + name)
	if enemies.get_child_count(): enemy_nodes = enemies.get_children()
	current_operation = NodeOperation.REMOVE
	_timer = _time_gap
	_set_patrols_enabled(false)


func _set_patrols_enabled(enabled: bool) -> void:
	if not patrols: return
	patrols.process_mode = Node.PROCESS_MODE_INHERIT if enabled \
		else Node.PROCESS_MODE_DISABLED
