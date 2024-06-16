class_name CharacterAnimations
extends Node3D


@export var movement_animations: MovementAnimations
@export var walk_or_jog_animations: WalkOrJogAnimations
@export var jump_animations: JumpAnimations
@export var attack_animations: AttackAnimations
@export var block_animations: BlockAnimations
@export var parry_animations: ParryAnimations
@export var hit_and_death_animations: HitAndDeathAnimations
@export var dizzy_animations: DizzyAnimations
@export var drink_animations: DrinkAnimations
@export var sitting_animations: SittingAnimations

@onready var anim_tree: AnimationTree = $AnimationTree


func _ready() -> void:
	anim_tree.active = true
