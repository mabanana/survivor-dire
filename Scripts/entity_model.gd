class_name EntityModel

var name: String
var hp: int
var damage: int
var entity_type: CoreModel.EntityType
var position: Vector2
var speed: int
var loot_class: int

const PH_POSITION = Vector2(INF, INF)

func _init(entity_type) -> void:
	self.entity_type = entity_type
	match entity_type:
		CoreModel.EntityType.player:
			self.name = "Player"
			self.hp = 100
			self.damage = 0
			self.speed = 0
			self.position = PH_POSITION
			self.loot_class = CoreModel.LootClass.BASIC_1
		CoreModel.EntityType.square:
			self.name = "Square"
			self.hp = 1
			self.damage = 1
			self.speed = 100
			self.position = PH_POSITION
			self.loot_class = CoreModel.LootClass.BASIC_1
		_:
			prints(entity_type, "is an unknown entity type. Failed to Initialize EntityModel.")
