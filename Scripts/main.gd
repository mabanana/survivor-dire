class_name Main
extends Node2D

@onready var player_scene: PackedScene = preload("res://Scenes/player.tscn")
@onready var square_scene: PackedScene = preload("res://Scenes/square_enemy.tscn")
@onready var circle_scene: PackedScene = preload("res://Scenes/circle_enemy.tscn")
@onready var donut_scene: PackedScene = preload("res://Scenes/donut_enemy.tscn")
@onready var sm_circle_scene: PackedScene = preload("res://Scenes/small_circle_enemy.tscn")
@onready var hud_scene: PackedScene = preload("res://Scenes/hud.tscn")
@onready var bullet_scene: PackedScene = preload("res://Scenes/bullet.tscn")
@onready var damage_number_scene: PackedScene = preload("res://Scenes/damage_number.tscn")
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
var sound_manager: SoundManager

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
	sound_manager = SoundManager.new(self)
	
	input_handler.bind(core, core_changed)
	sound_manager.bind(core, core_changed)
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
				var rand = randi_range(0,2)
				if rand == 1:
					_spawn_enemy(CoreModel.EntityType.circle)
				elif rand == 2:
					_spawn_enemy(CoreModel.EntityType.donut)
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
			var dist_to_player = player.position - core.scene.nodes[rid].position
			if core.scene.entities[rid].hp <= 0:
				_on_enemy_death(rid)
				_despawn_enemy(rid)
			elif dist_to_player.length() > 2000:
				_despawn_enemy(rid)
	core.emit_changed(core.Context.map_update, null)

func _random_spawn_pos():
	var x_or_y = randi_range(0,1)
	var spawn_pos = Vector2.ZERO
	if x_or_y:
		spawn_pos.x = randi_range(0,spawn_rect.x) - spawn_rect.x/2
		spawn_pos.y = spawn_rect.y * randi_range(0,1) - spawn_rect.y/2
	else:
		spawn_pos.x = spawn_rect.x * randi_range(0,1) - spawn_rect.x/2
		spawn_pos.y = randi_range(0,spawn_rect.y) - spawn_rect.y/2
	return spawn_pos
	
	
func _spawn_enemy(entity_type, spawn_pos = _random_spawn_pos()):
	var node: GameCharacter
	match entity_type:
		core.EntityType.square:
			node = square_scene.instantiate()
		core.EntityType.circle:
			node = circle_scene.instantiate()
		core.EntityType.small_circle:
			node = sm_circle_scene.instantiate()
		core.EntityType.donut:
			node = donut_scene.instantiate()
		_:
			print("entity type not found, failed to instantiate node scene.")
			return
	
	node.position = spawn_pos + core.scene.player_pos
	node.entity_type = entity_type
	node.bind(core, core_changed)
	_add_child_to_scene(node)
	node.position = spawn_pos + core.scene.player_pos
	prints("Enemy spawned at", node.position)

# TODO despawn upon distance to player too high
func _despawn_enemy(rid):
	var node: GameCharacter = core.scene.nodes[rid]
	var entity: EntityModel = core.scene.entities[rid]
	prints(entity.name, "despawned")
	
	core.scene.entities.erase(rid)
	core.scene.nodes.erase(rid)
	node.die()

func _on_enemy_death(rid):
	var entity: EntityModel = core.scene.entities[rid]
	print("a %s has been killed." % [entity.name])
	# TODO: put progression somewhere else
	core.progress.exp += 1
	core.progress.kill_count += 1
	core.emit_changed(core.Context.enemy_died, {
		CoreModel.PKey.target_rid: rid,
		CoreModel.PKey.target_position: entity.position,
		CoreModel.PKey.loot_class: entity.loot_class,
	})

func _damage_event(payload):
	var target_rids = payload[core.PKey.target_rid]
	var dealer = payload[core.PKey.dealer_rid]
	var amount = payload[core.PKey.amount]
	var attack_type = payload[core.PKey.attack_type]
	
	for rid in target_rids:
		_spawn_bullet(core.scene.nodes[rid].position)
		_spawn_damage_number(core.scene.nodes[rid].position, amount)
		core.scene.entities[rid].hp -= amount
		print("%s took %s damage from %s" % [
			core.scene.nodes[rid].name,
			amount,
			core.scene.nodes[dealer].name
		])
		core.emit_changed(core.Context.damage_ended, {
			core.PKey.target_rid : rid,
			core.PKey.amount : amount,
			core.PKey.dealer_rid : dealer,
			core.PKey.attack_type : attack_type,
		})
		
		var node:CharacterBody2D = core.scene.nodes[rid]
		node.velocity = (node.position - player.position).normalized()*30
		node.move_and_slide()
		if core.scene.entities[rid].hp != core.scene.entities[rid].max_hp:
			node.hp_bar.visible = true
			node.hp_bar.value = 100 * core.scene.entities[rid].hp / core.scene.entities[rid].max_hp

func _on_core_changed(context, payload):
	if context == core.Context.damage_started:
		_damage_event(payload)
	elif context == core.Context.circle_died:
		_spawn_small_circles(payload[core.PKey.target_position])
		prints("Main: spawning small circles from circle death at", payload[core.PKey.target_position])
	elif context == core.Context.donut_center_click:
		_on_donut_center_click()

func _spawn_small_circles(position):
	var pos_list = []
	var R = 10
	for i in range(3):
		var rel_pos = R / 2 * Vector2.UP
		rel_pos = rel_pos.rotated(360/3 * i)
		pos_list.append(rel_pos)
	for pos in pos_list:
		_spawn_enemy(core.EntityType.small_circle, pos + position - player.position)
	
func _on_donut_center_click():
	core.progress.combo = 0
	print("Main: Don't press the center of the donut, combo removed")

func _spawn_bullet(dest):
	var new_bullet: BulletMesh = bullet_scene.instantiate()
	new_bullet.position = player.position
	new_bullet.dest = dest
	add_child(new_bullet)

func _spawn_damage_number(pos, amount):
	var num = damage_number_scene.instantiate()
	num.text = str(roundi(amount))
	num.position = pos
	add_child(num)
