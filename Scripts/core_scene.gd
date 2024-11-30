class_name CoreScene

var entities: Dictionary # { rid: EntityModel }
var nodes: Dictionary # { rid : node_reference }

func _init() -> void:
	entities = {}
	nodes = {}
