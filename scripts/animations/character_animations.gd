class_name CharacterAnimations
extends Node3D


@onready var movement_animations: MovementAnimations = $MovementAnimations
@onready var jump_animations: JumpAnimations = $JumpAnimations
@onready var attack_animations: AttackAnimations = $AttackAnimations
@onready var block_animations: BlockAnimations = $BlockAnimations
@onready var parry_animations: ParryAnimations = $ParryAnimations
@onready var hit_and_death_animations: HitAndDeathAnimations = $HitAndDeathAnimations
@onready var dizzy_animations: DizzyAnimations = $DizzyAnimations

@onready var anim_tree: AnimationTree = $AnimationTree


func _ready() -> void:
	anim_tree.active = true
