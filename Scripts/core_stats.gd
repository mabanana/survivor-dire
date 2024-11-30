class_name CoreStats

# Player Stats
var player_pos: Vector2
var hp: int
var xp: int
var damage_amp: float
var damage_reduc: float
var attack_speed: float
var move_speed: float

# Start Constants
const START_POS = Vector2(0,0)
const START_HP = 100
const START_XP = 0
const START_DA = 1.0
const START_AS = 1.0
const START_MS = 300.0

# static function that returns a fresh player
static func create_new_player_stats():
	var new = CoreStats.new()
	new.player_pos = START_POS
	new.hp = START_HP
	new.xp = START_XP
	new.damage_amp = START_DA
	new.attack_speed = START_AS
	new.move_speed = START_MS
	return new
