class_name CoreModel

var stats: CoreStats
var progress: CoreProgression
var scene: CoreScene
var signal_bus: CoreSignalBus
var rid_counter: int

signal core_changed

enum Context {
	map_update,
	mouse_button_pressed,
	mouse_button_released,
	key_input_pressed,
	key_input_released,
	event_mouse_moved,
	damage_started,
	damage_ended,
	enemy_died,
	loot_dropped,
}

enum EntityType {
	square,
	player,
	circle,
	small_circle,
	doughnut,
}

enum PKey {
	target_rid,
	dealer_rid,
	target_position,
	input_action,
	input_as_text,
	mouse_relative,
	mouse_position,
	amount,
	num_targets,
	loot_class,
	loot_id,
}

enum LootClass {
	BASIC_1,
	ELITE_1,
	ITEM_LIST,
}

func _init() -> void:
	stats = CoreStats.create_new_player_stats()
	progress = CoreProgression.new()
	scene = CoreScene.new()
	signal_bus = CoreSignalBus.new(self, core_changed)

func gen_id():
	rid_counter += 1
	return rid_counter

func emit_changed(context, payload):
	signal_bus.emit_core_changed(context, payload)
