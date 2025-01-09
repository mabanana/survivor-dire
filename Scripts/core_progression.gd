class_name CoreProgression

var items: Dictionary
var gold: int
var exp: int
var kill_count: int
var combo: int

func _init() -> void:
	# TODO: fetch artefact list from data
	items = {
		"Attack+": 0,
		"Attackspeed+": 0
	}
	gold = 0
	exp = 0
	kill_count = 0
	combo = 0
