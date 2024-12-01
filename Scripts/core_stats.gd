class_name CoreStats

# Player Stats
var hp: int
var xp: int
var damage_amp: float
var damage_reduc: float
var attack_speed: float
var move_speed: float
var spell_radius: int
var spell_cooldown: int
var attack_range: int

# Start Constants
const START_HP = 100
const START_XP = 0
const START_DA = 1.0
const START_AS = 1.0
const START_MS = 300.0
const START_SR = 30.0
const START_SCD = 30
const START_RG = 250

# static function that returns a fresh player
static func create_new_player_stats():
	var new = CoreStats.new()
	new.hp = START_HP
	new.xp = START_XP
	new.damage_amp = START_DA
	new.attack_speed = START_AS
	new.move_speed = START_MS
	new.spell_radius = START_SR
	new.spell_cooldown = START_SCD
	new.attack_range = START_RG
	return new
