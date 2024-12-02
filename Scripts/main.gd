class_name Main
extends Node2D

@onready var player_scene: PackedScene = preload("res://Scenes/player.tscn")
@onready var square_scene: PackedScene = preload("res://Scenes/square_enemy.tscn")
var player: PlayerController

var core: CoreModel
signal core_changed

@export var map_update_freq: float
@export var enemy_spawn_time: float

var update_cd: Countdown
var enemy_spawn_cd: Countdown
var spawn_rect: Vector2
var aim_cast: AimCast
var input_handler: InputHandler

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	core = CoreModel.new()
	core_changed.connect(_on_core_changed)
	
	update_cd = Countdown.new(1/map_update_freq)
	enemy_spawn_cd = Countdown.new(1/enemy_spawn_time)
	
	player = player_scene.instantiate()
	player.entity_type = CoreModel.EntityType.player
	#aim_cast = AimCast.new()
	input_handler = InputHandler.new()
	
	input_handler.bind(core, core_changed)
	#aim_cast.bind(core, core_changed)
	
	add_child(input_handler)
	#add_child(aim_cast)
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
	for cd in [update_cd, enemy_spawn_cd]:
		var tick = cd.tick(delta)
		if tick <= 0:
			if cd == update_cd:
				cd.reset_cd()
				_update_map()
			elif cd == enemy_spawn_cd:
				cd.reset_cd()
				_spawn_enemy(CoreModel.EntityType.square)

func _add_child_to_scene(child, bind = true):
	child.rid = core.gen_id()
	if bind:
		child.bind(core, core_changed)
	core.scene.entities[child.rid] = EntityModel.new(child.entity_type)
	core.scene.nodes[child.rid] = child
	add_child(child)

func _update_map():
	core.scene.player_pos = player.position
	for rid in core.scene.entities.keys():
		core.scene.entities[rid].position = core.scene.nodes[rid].position
		if rid != player.rid: # for enemies
			if core.scene.entities[rid].hp <= 0:
				_despawn_enemy(rid)
	core_changed.emit(core.Context.map_update, null)

func _spawn_enemy(entity_type):
	var x_or_y = randi_range(0,1)
	var spawn_pos = Vector2.ZERO
	if x_or_y:
		spawn_pos.x = randi_range(0,spawn_rect.x) - spawn_rect.x/2
		spawn_pos.y = spawn_rect.y * randi_range(0,1) - spawn_rect.y/2
	else:
		spawn_pos.x = spawn_rect.x * randi_range(0,1) - spawn_rect.x/2
		spawn_pos.y = randi_range(0,spawn_rect.y) - spawn_rect.y/2
		
	var node: GameCharacter = square_scene.instantiate()
	node.position = spawn_pos + core.scene.player_pos
	node.entity_type = entity_type
	node.bind(core, core_changed)
	_add_child_to_scene(node)
	node.position = spawn_pos + core.scene.player_pos
	prints("Enemy spawned at", node.position)

func _despawn_enemy(rid):
	var enemy = core.scene.nodes[rid]
	prints(core.scene.nodes[rid].entity_type, "despawned")
	core.scene.entities.erase(rid)
	core.scene.nodes.erase(rid)
	enemy.die()

func _damage_event(target_rids, amount, dealer = player.rid):
	for rid in target_rids:
		core.scene.entities[rid].hp -= amount
		print("%s took %s damage from %s" % [
			core.scene.nodes[rid].name,
			amount,
			core.scene.nodes[dealer].name
		])
		var node:CharacterBody2D = core.scene.nodes[rid]
		node.velocity = (node.position - player.position).normalized()*30
		node.move_and_slide()

func _on_core_changed(context, payload):
	if context == core.Context.damage_started:
		_damage_event(
			payload[core.PKey.target_rid], 
			payload[core.PKey.amount], 
			payload[core.PKey.dealer_rid]
			)
