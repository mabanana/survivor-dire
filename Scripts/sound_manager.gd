class_name SoundManager

var core: CoreModel
var core_changed: Signal
var main_scene: Main
var sounds: Dictionary
var sounds_dir = "res://Resources/Sounds/"
var master_player: AudioStreamPlayer
var bgm_player: AudioStreamPlayer
var notif_player: AudioStreamPlayer2D
var auto_player: AudioStreamPlayer
var click_player: AudioStreamPlayer

func _init(main_scene: Main):
	self.main_scene = main_scene
	init_audio_stream_players()
	
	sounds = {}
	_init_sounds_dict()

func _init_sounds_dict():
	var folder_dir_access = DirAccess.open(sounds_dir)
	for file_name in folder_dir_access.get_files():
		#print("sound file found: ", file_name)
		var split_file_name = file_name.split(".")
		var sound_name = split_file_name[0]
		var file_type = split_file_name[len(split_file_name) - 1]
		if file_type in ["wav", "ogg", "mp3"]:
			sounds[sound_name] = sounds_dir + "/" + file_name

func init_audio_stream_players():
	master_player = AudioStreamPlayer.new()
	bgm_player = AudioStreamPlayer.new()
	notif_player = AudioStreamPlayer2D.new()
	auto_player = AudioStreamPlayer.new()
	click_player = AudioStreamPlayer.new()
	
	master_player.bus = "Master"
	bgm_player.bus = "BGM"
	notif_player.bus = "Notification"
	auto_player.bus = "AutoHit"
	click_player.bus = "ClickHit"
	
	
	auto_player.set_max_polyphony(10)
	
	main_scene.add_child(master_player)
	main_scene.add_child(bgm_player)
	main_scene.add_child(notif_player)
	main_scene.add_child(auto_player)
	main_scene.add_child(click_player)


func bind(core: CoreModel, core_changed):
	self.core = core
	self.core_changed = core_changed
	
	core_changed.connect(_on_core_changed)

func _on_core_changed(context, payload):
	if context == core.Context.damage_ended:
		match payload[core.PKey.attack_type]:
			"auto":
				_play_audio("auto_attack", -15, "AutoHit", Vector2(1.2,1.9))
			"aoe":
				_play_audio("aoe_attack", -15, "ClickHit", Vector2(0.8,0.9))
			"click":
				_play_audio("click_attack", -18, "ClickHit", Vector2(0.8,0.9))
			_:
				_play_audio("auto_attack", -15, "AutoHit", Vector2(1.8,1.9))
	elif context == core.Context.loot_dropped:
		match payload[core.PKey.loot_type]:
			"Gold":
				_play_audio("gold_pickup", 0, "Notification", Vector2(0.8,0.9))
			"HP":
				_play_audio("hp_pickup", 0, "Notification", Vector2(0.8,0.9))
			"XP":
				_play_audio("xp_pickup", 0, "Notification", Vector2(0.8,0.9))
			"Artefact":
				_play_audio("artefact_pickup", 0, "Notification", Vector2(0.8,0.9))
			_:
				pass
		
# TODO: use finite number of audio_players instead of instantiating new ones
func _play_audio(sound_name: String, db_offset: float, bus = "Master", pitch_range: Vector2 = Vector2(0.95, 1.05), position: Vector2 = Vector2.ZERO):
	var audio_player
	match bus:
		"Master":
			audio_player = master_player
		"BGM":
			audio_player = bgm_player
		"Notification":
			audio_player = notif_player
		"AutoHit":
			audio_player = auto_player
		"ClickHit":
			audio_player = click_player
		_:
			audio_player = master_player
	audio_player.volume_db = db_offset
	audio_player.stream = load(sounds[sound_name])
	audio_player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)
	if bus == "Notification":
		audio_player.position = core.scene.player_pos + Vector2.LEFT * 5
	audio_player.play()
	
