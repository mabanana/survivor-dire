class_name CoreModel

var stats: CoreStats
var inventory: CoreInventory
var scene: CoreScene
var rid_counter: int

enum Context {
	map_update,
}

enum EntityType {
	square,
	player,
}

func _init() -> void:
	stats = CoreStats.create_new_player_stats()
	inventory = CoreInventory.new()
	scene = CoreScene.new()

func gen_id():
	rid_counter += 1
	return rid_counter
