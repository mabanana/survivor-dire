class_name CoreScene

var player_pos: Vector2
var entities: Dictionary # { rid: EntityModel }
var nodes: Dictionary # { rid : node_reference }

func _init() -> void:
	entities = {}
	nodes = {}
	player_pos = Vector2(0,0)
