class_name EntityModel

var hp: int
var damage: int
var entity_type: CoreModel.EntityType
var position: Vector2
var speed: int

const PH_POSITION = Vector2(INF, INF)

func _init(entity_type) -> void:
	self.entity_type = entity_type
	match entity_type:
		CoreModel.EntityType.player:
			self.hp = 100
			self.damage = 0
			self.speed = 0
			self.position = PH_POSITION
		CoreModel.EntityType.square:
			self.hp = 1
			self.damage = 1
			self.speed = 100
			self.position = PH_POSITION
		_:
			prints(entity_type, "is an unknown entity type. Failed to Initialize EntityModel.")
