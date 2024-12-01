class_name Main
extends Node2D

@onready var player_scene: PackedScene = preload("res://Scenes/player.tscn")
@onready var square_scene: PackedScene = preload("res://Scenes/square_enemy.tscn")
var player: PlayerController

var core: CoreModel
signal core_changed

@export var map_update_freq: float
@export var enemy_spawn_freq: float
var update_cd: Countdown
var enemy_spawn_cd: Countdown
var spawn_rect: Vector2
var aim_cast: AimCast
var input_handler: InputHandler

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	core = CoreModel.new()
	
	update_cd = Countdown.new(1/map_update_freq)
	enemy_spawn_cd = Countdown.new(1/enemy_spawn_freq)
	
	player = player_scene.instantiate()
	player.entity_type = CoreModel.EntityType.player
	aim_cast = AimCast.new()
	input_handler = InputHandler.new()
	
	input_handler.bind(core, core_changed)
	aim_cast.bind(core, core_changed)
	
	add_child(input_handler)
	add_child(aim_cast)
	_add_child_to_scene(player)
	
	spawn_rect = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
		)
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	input_handler.handle_input(event)

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

func _add_child_to_scene(child, bind = true):
	child.rid = core.gen_id()
	if bind:
		child.bind(core, core_changed)
	core.scene.entities[child.rid] = EntityModel.new(child.entity_type)
	core.scene.nodes[child.rid] = child
	add_child(child)

func _update_map():
	core.stats.player_pos = player.position
	var dist_closest
	for rid in core.scene.entities.keys():
		core.scene.entities[rid].position = core.scene.nodes[rid].position
		if rid != player.rid: # for enemies
			var player_dist = (core.scene.entities[rid].position - player.position).length()
			if (!dist_closest or player_dist < dist_closest) and player_dist < 500:
				dist_closest = player_dist
				player.rid_closest = rid
			
			if core.scene.entities[rid].hp <= 0:
				_despawn_enemy(rid)

func _spawn_enemy(entity_type):
	var x_or_y = randi_range(0,1)
	var spawn_pos: Vector2
	if x_or_y:
		spawn_pos = Vector2(randi_range(0,spawn_rect.x), spawn_rect.y * randi_range(0,1))
	else:
		spawn_pos = Vector2(spawn_rect.x * randi_range(0,1), randi_range(0,spawn_rect.y))
	var node: GameCharacter = square_scene.instantiate()
	node.position = spawn_pos + core.stats.player_pos
	node.entity_type = entity_type
	node.bind(core, core_changed)
	_add_child_to_scene(node)
	node.position = spawn_pos + core.stats.player_pos
	prints("Enemy spawned at", node.position)

func _despawn_enemy(rid):
	prints(core.scene.nodes[rid])
	core.scene.entities.erase(rid)
	core.scene.nodes[rid].queue_free()
	core.scene.nodes.erase(rid)
	
