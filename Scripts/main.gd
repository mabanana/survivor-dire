class_name Main
extends Node2D

var player_scene: PackedScene
var square_scene: PackedScene
var player: PlayerController

var core: CoreModel
var core_changed: Signal

@export var map_update_freq: float
@export var enemy_spawn_freq: float
var update_cd: Countdown
var enemy_spawn_cd: Countdown
var screen_bounds: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_bounds = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
		)
	core = CoreModel.new()
	update_cd = Countdown.new(1/map_update_freq)
	enemy_spawn_cd = Countdown.new(1/enemy_spawn_freq)
	player_scene = load("res://Scenes/player.tscn")
	square_scene = load("res://square_enemy.tscn")
	_add_player_to_scene()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var tick = update_cd.tick(delta)
	if tick <= 0:
		update_cd.reset_cd()
		_update_map()
	
	tick = enemy_spawn_cd.tick(delta)
	if tick <= 0:
		enemy_spawn_cd.reset_cd()
		_spawn_enemy(CoreModel.EntityType.square)

func _add_player_to_scene():
	player = player_scene.instantiate()
	player.bind(core, core_changed)
	_add_child_to_scene(player)

func _add_child_to_scene(child):
	child.rid = core.gen_id()
	core.scene.entities[child.rid] = EntityModel.new(child.entity_type)
	core.scene.nodes[child.rid] = child
	add_child(child)

func _update_map():
	core.stats.player_pos = player.position
	for rid in core.scene.entities.keys():
		core.scene.entities[rid].position = core.scene.nodes[rid].position
	

func _spawn_enemy(entity_type):
	var x_or_y = randi_range(0,1)
	var spawn_pos: Vector2
	if x_or_y:
		spawn_pos = Vector2(randi_range(0,screen_bounds.x), screen_bounds.y * randi_range(0,1))
	else:
		spawn_pos = Vector2(screen_bounds.x * randi_range(0,1), randi_range(0,screen_bounds.y))
	var node: GameCharacter = square_scene.instantiate()
	node.position = spawn_pos + core.stats.player_pos
	node.entity_type = entity_type
	node.bind(core, core_changed)
	_add_child_to_scene(node)
	node.position = spawn_pos + core.stats.player_pos
	prints("Enemy spawned at", node.position)
