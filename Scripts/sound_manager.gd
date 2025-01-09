class_name SoundManager

var core: CoreModel
var core_changed: Signal
var main_scene: Main
var sounds: Dictionary
var sounds_dir = "res://Resources/Sounds/"
var audio_stream_player: AudioStreamPlayer

func _init(main_scene: Main):
	self.main_scene = main_scene
	audio_stream_player = AudioStreamPlayer.new()
	audio_stream_player.set_max_polyphony(10)
	main_scene.add_child(audio_stream_player)
	sounds = {}
	var folder_dir_access = DirAccess.open(sounds_dir)
	for file_name in folder_dir_access.get_files():
		#print("sound file found: ", file_name)
		var split_file_name = file_name.split(".")
		var sound_name = split_file_name[0]
		var file_type = split_file_name[len(split_file_name) - 1]
		if file_type in ["wav", "ogg", "mp3"]:
			sounds[sound_name] = sounds_dir + "/" + file_name

func bind(core: CoreModel, core_changed):
	self.core = core
	self.core_changed = core_changed
	
	core_changed.connect(_on_core_changed)

func _on_core_changed(context, payload):
	if context == core.Context.damage_ended:
		match payload[core.PKey.attack_type]:
			"auto":
				_spawn_audio_player("auto_attack", -10, "Master", Vector2(1.8,1.9))
			"aoe":
				_spawn_audio_player("aoe_attack", -20, "Master", Vector2(0.8,0.9))
			"click":
				_spawn_audio_player("click_attack", -18, "Master", Vector2(0.8,0.9))
			_:
				_spawn_audio_player("auto_attack", -10, "Master", Vector2(1.8,1.9))
	elif context == core.Context.loot_dropped:
		match payload[core.PKey.loot_type]:
			"Gold":
				_spawn_audio_player("gold_pickup", 0, "Notification", Vector2(0.8,0.9))
			"HP":
				_spawn_audio_player("hp_pickup", 0, "Notification", Vector2(0.8,0.9))
			"XP":
				_spawn_audio_player("xp_pickup", 0, "Notification", Vector2(0.8,0.9))
			"Artefact":
				_spawn_audio_player("artefact_pickup", 0, "Notification", Vector2(0.8,0.9))
			_:
				pass
		
# TODO: use finite number of audio_players instead of instantiating new ones
func _spawn_audio_player(sound_name: String, db_offset: float, bus = "Master", pitch_range: Vector2 = Vector2(0.95, 1.05), position: Vector2 = Vector2.ZERO):
	var audio_player = audio_stream_player
	audio_player.volume_db = db_offset
	audio_player.stream = load(sounds[sound_name])
	audio_player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)
	audio_player.play()
	
