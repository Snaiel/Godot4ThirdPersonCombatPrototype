class_name CharacterAnimations
extends Node3D


@export var debug: bool = false

var _recipients: Dictionary

@onready var animations: Node = $Animations
@onready var audio: Node = $Audio
@onready var anim_tree: AnimationTree = $AnimationTree


func _ready() -> void:
	anim_tree.active = true
	_add_base_recipient(animations)
	_add_base_recipient(audio)
	if debug: print(_recipients)


func execute(target: String, method: StringName, args) -> void:
	if debug: prints("EXECUTE", target, method, args)
	
	if not _recipients.has(target):
		return
	
	var node: Node = _recipients[target]
	
	if not node.has_method(method):
		return
	
	if args == null:
		args = []
	
	node.callv(method, args)


func _add_base_recipient(node: Node) -> void:
	_add_recipients(node, node.get_parent())


func _add_recipients(node: Node, root: Node) -> void:
	if node.get_parent() != root:
		if not (node is BaseAnimations or node is AudioStreamPlayer3D):
			return
		_recipients[str(root.get_path_to(node))] = node
	for child in node.get_children():
		_add_recipients(child, root)
