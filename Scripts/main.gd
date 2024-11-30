class_name Main
extends Node2D

var player_scene: PackedScene
var player: PlayerController

var core: CoreModel
var core_changed: Signal

var timer: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	core = CoreModel.new()
	player_scene = load("res://Scenes/player.tscn")
	_add_player_to_scene()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _add_player_to_scene():
	player = player_scene.instantiate()
	player.rid = core.gen_id()
	player.bind(core, core_changed)
	_add_child_to_scene(player)

func _add_child_to_scene(child):
	core.scene.entities[child.rid] = child.entity_type
	core.scene.nodes[child.rid] = child
	add_child(child)
