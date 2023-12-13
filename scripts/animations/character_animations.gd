class_name CharacterAnimations
extends Node3D


@onready var movement_animations: MovementAnimations = $MovementAnimations
@onready var jump_animations: JumpAnimations = $JumpAnimations
@onready var attack_animations: AttackAnimations = $AttackAnimations
@onready var block_animations: BlockAnimations = $BlockAnimations
@onready var hit_and_death_animations: HitAndDeathAnimations = $HitAndDeathAnimations

@onready var anim_tree: AnimationTree = $AnimationTree


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_tree.active = true
