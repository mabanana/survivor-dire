class_name CoreModel

var stats: CoreStats
var inventory: CoreInventory
var scene: CoreScene
var rid_counter: int

enum Context {
	map_update,
	mouse_button_pressed,
	mouse_button_released,
	key_input_pressed,
	key_input_released,
	event_mouse_moved,
	damage_started,
	damage_ended,
}

enum EntityType {
	square,
	player,
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
}

func _init() -> void:
	stats = CoreStats.create_new_player_stats()
	inventory = CoreInventory.new()
	scene = CoreScene.new()

func gen_id():
	rid_counter += 1
	return rid_counter
