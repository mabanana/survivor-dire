class_name Main
extends Node2D

@onready var player_scene: PackedScene = preload("res://Scenes/player.tscn")
@onready var square_scene: PackedScene = preload("res://Scenes/square_enemy.tscn")
@onready var hud_scene: PackedScene = preload("res://Scenes/hud.tscn")
var player: PlayerController

var core: CoreModel
var core_changed: Signal

@export var map_update_freq: float
@export var enemy_spawn_time: float

var update_cd: Countdown
var enemy_spawn_cd: Countdown
var spawn_rect: Vector2
var aim_cast: AimCast
var input_handler: InputHandler
var hud: HudController
var loot_manager: LootManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	core = CoreModel.new()
	core_changed = core.core_changed
	core_changed.connect(_on_core_changed)
	
	update_cd = Countdown.new(1/map_update_freq)
	enemy_spawn_cd = Countdown.new(1/enemy_spawn_time)
	
	player = player_scene.instantiate()
	player.entity_type = CoreModel.EntityType.player
	hud = hud_scene.instantiate()
	#aim_cast = AimCast.new()
	input_handler = InputHandler.new(self)
	loot_manager = LootManager.new()
	
	input_handler.bind(core, core_changed)
	hud.bind(core, core_changed)
	loot_manager.bind(core, core_changed)
	#aim_cast.bind(core, core_changed)
	
	%CanvasLayer.add_child(hud)
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
				#TODO: randomize spawn differently
				var rand = randi_range(0,1)
				if rand == 1:
					_spawn_enemy(CoreModel.EntityType.circle)
				else:
					_spawn_enemy(CoreModel.EntityType.square)

func _add_child_to_scene(child: Node2D, bind = true):
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
				_on_enemy_death(rid)
				_despawn_enemy(rid)
	core.emit_changed(core.Context.map_update, null)

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
	if entity_type == core.EntityType.circle:
		node.set_script(load("res://Scripts/circle_enemy.gd"))
	node.position = spawn_pos + core.scene.player_pos
	node.entity_type = entity_type
	node.bind(core, core_changed)
	_add_child_to_scene(node)
	node.position = spawn_pos + core.scene.player_pos
	prints("Enemy spawned at", node.position)

func _despawn_enemy(rid):
	var node: GameCharacter = core.scene.nodes[rid]
	var entity: EntityModel = core.scene.entities[rid]
	prints(entity.name, "despawned")
	core.emit_changed(core.Context.enemy_died, {
		CoreModel.PKey.target_rid: rid,
		CoreModel.PKey.target_position: entity.position,
		CoreModel.PKey.loot_class: entity.loot_class,
	})
	core.scene.entities.erase(rid)
	core.scene.nodes.erase(rid)
	node.die()

func _on_enemy_death(rid):
	var entity: EntityModel = core.scene.entities[rid]
	print("a %s has been killed." % [entity.name])
	core.progress.exp += 1
	core.progress.kill_count += 1
	

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
		if core.scene.entities[rid].hp != core.scene.entities[rid].max_hp:
			node.hp_bar.visible = true
			node.hp_bar.value = 100 * core.scene.entities[rid].hp / core.scene.entities[rid].max_hp

func _on_core_changed(context, payload):
	if context == core.Context.damage_started:
		_damage_event(
			payload[core.PKey.target_rid], 
			payload[core.PKey.amount], 
			payload[core.PKey.dealer_rid]
			)
