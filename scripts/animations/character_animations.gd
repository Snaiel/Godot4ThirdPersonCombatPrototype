class_name CharacterAnimations
extends Node3D


@onready var anim_tree: AnimationTree = $AnimationTree


func _ready() -> void:
	anim_tree.active = true
