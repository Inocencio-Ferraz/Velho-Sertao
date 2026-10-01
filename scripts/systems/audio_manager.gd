extends Node

const MUSIC_VOLUME: float = 0.75
const AMBIENCE_VOLUME: float = 0.62
const DINOSAUR_ROAR_PATH: String = "res://assets/audio/sfx/sfx_dinosaur_roar_01.ogg"

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var ambience_player: AudioStreamPlayer = $AmbiencePlayer
@onready var machete_player: AudioStreamPlayer = $MachetePlayer
@onready var impact_player: AudioStreamPlayer = $ImpactPlayer
@onready var enemy_death_player: AudioStreamPlayer = $EnemyDeathPlayer
@onready var water_player: AudioStreamPlayer = $WaterPlayer
@onready var dinosaur_roar_player: AudioStreamPlayer = $DinosaurRoarPlayer
@onready var pistol_player: AudioStreamPlayer = $PistolPlayer

var _sfx_players: Dictionary = {}

func _ready() -> void:
	var existing_manager := get_tree().get_first_node_in_group("game_audio")
	if existing_manager and existing_manager != self:
		queue_free()
		return
	add_to_group("game_audio")
	_sfx_players = {
		"machete": machete_player,
		"impact": impact_player,
		"enemy_death": enemy_death_player,
		"water": water_player,
		"dinosaur_roar": dinosaur_roar_player,
		"pistol": pistol_player
	}
	if ResourceLoader.exists(DINOSAUR_ROAR_PATH):
		dinosaur_roar_player.stream = load(DINOSAUR_ROAR_PATH) as AudioStream

	var music_stream := music_player.stream as AudioStreamMP3
	if music_stream:
		music_stream.loop = true
	var ambience_stream := ambience_player.stream as AudioStreamOggVorbis
	if ambience_stream:
		ambience_stream.loop = true

	music_player.volume_db = linear_to_db(MUSIC_VOLUME)
	ambience_player.volume_db = linear_to_db(AMBIENCE_VOLUME)
	music_player.play()
	ambience_player.play()

func play_sfx(effect_name: String) -> void:
	var player := _sfx_players.get(effect_name) as AudioStreamPlayer
	if player and player.stream != null:
		player.play()

func play_dinosaur_roar() -> float:
	if dinosaur_roar_player.stream == null:
		return 0.0
	dinosaur_roar_player.play()
	return dinosaur_roar_player.stream.get_length()

func set_game_paused(paused: bool) -> void:
	for player in [music_player, ambience_player, machete_player, impact_player, enemy_death_player, water_player, dinosaur_roar_player, pistol_player]:
		player.stream_paused = paused
