class_name EntityModel

var name: String
var hp: int
var max_hp: int
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
			self.max_hp = hp
			self.damage = 0
			self.speed = 0
			self.position = PH_POSITION
			self.loot_class = CoreModel.LootClass.BASIC_1
		CoreModel.EntityType.square:
			self.name = "Square"
			self.hp = 10
			self.max_hp = hp
			self.damage = 1
			self.speed = 150
			self.position = PH_POSITION
			self.loot_class = CoreModel.LootClass.BASIC_1
		CoreModel.EntityType.circle:
			self.name = "Circle"
			self.hp = 100
			self.max_hp = hp
			self.damage = 50
			self.speed = 120
			self.position = PH_POSITION
			self.loot_class = CoreModel.LootClass.BASIC_1
		CoreModel.EntityType.small_circle:
			self.name = "Small Circle"
			self.hp = 10
			self.max_hp = hp
			self.damage = 5
			self.speed = 200
			self.position = PH_POSITION
			self.loot_class = CoreModel.LootClass.BASIC_1
		CoreModel.EntityType.doughnut:
			self.name = "Doughnut"
			self.hp = 20
			self.max_hp = hp
			self.damage = 20
			self.speed = 100
			self.position = PH_POSITION
			self.loot_class = CoreModel.LootClass.BASIC_1
		_:
			prints(entity_type, "is an unknown entity type. Failed to Initialize EntityModel.")
