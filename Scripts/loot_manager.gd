class_name LootManager

var core: CoreModel
var core_changed: Signal

var loot_classes: Dictionary

func _init():
	var loot_class_json = _load_json("res://Resources/JSON/loot_classes.json")
	for lc in loot_class_json.loot_classes:
		loot_classes[core.LootClass[lc.loot_class]] = lc.items

func drop_loot(loot_class: CoreModel.LootClass, target_name: String, target_position: Vector2):
	if loot_class or loot_class == 0:
		var loot_table = get_loot_table(loot_class)
		var loot = Randomizer.roll_loot(loot_table)
		var amount = 1
		if loot["type"] == "LootClass":
			drop_loot(core.LootClass[loot["name"]], target_name, target_position)
			return
		elif loot["type"] == "Gold":
			amount = randi_range(1,100)
			core.progress.gold += amount
		elif loot["type"] == "HP":
			amount = randi_range(1,10)
			core.stats.hp += amount
		elif loot["type"] == "XP":
			amount = randi_range(1,100)
			core.progress.exp += amount
		prints("Loot Dropped by", target_name, loot["name"], "x", amount)
		core_changed.emit(CoreModel.Context.loot_dropped, {
			CoreModel.PKey.loot_id: loot["name"],
			CoreModel.PKey.amount: amount,
		})
	else:
		print("no loot from this one.")


func get_loot_table(loot_class: CoreModel.LootClass):
	var loot_table = {}
	for item in loot_classes[loot_class]:
		loot_table[item] = item["weight"]
	return loot_table
	
func _load_json(path: String):
	var file = FileAccess.open(path,FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var parsed_json = JSON.parse_string(content)
	if parsed_json:
		return parsed_json

func bind(core, core_changed):
	self.core = core
	self.core_changed = core_changed
	
	core_changed.connect(_on_core_changed)

func _on_core_changed(context, payload):
	if context == core.Context.enemy_died:
		drop_loot(payload[CoreModel.PKey.loot_class], 
		core.scene.entities[payload[CoreModel.PKey.target_rid]].name, 
		payload[CoreModel.PKey.target_position])
