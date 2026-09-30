extends Node

const MUSIC_VOLUME: float = 0.75
const AMBIENCE_VOLUME: float = 0.62

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var ambience_player: AudioStreamPlayer = $AmbiencePlayer
@onready var machete_player: AudioStreamPlayer = $MachetePlayer
@onready var impact_player: AudioStreamPlayer = $ImpactPlayer
@onready var enemy_death_player: AudioStreamPlayer = $EnemyDeathPlayer
@onready var water_player: AudioStreamPlayer = $WaterPlayer

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
		"water": water_player
	}

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
	if player:
		player.play()

func set_game_paused(paused: bool) -> void:
	for player in [music_player, ambience_player, machete_player, impact_player, enemy_death_player, water_player]:
		player.stream_paused = paused
