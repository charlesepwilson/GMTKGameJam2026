extends Node

@export var playlist: Array[AudioStream] = []
@onready var track_1: AudioStreamPlayer = $Track1
@onready var track_2: AudioStreamPlayer = $Track2

var current_song_index: int = 0

func _ready() -> void:
	_set_stream()
	track_1.finished.connect(_on_stream_finish)
	track_1.play()

func _set_stream():
	if playlist:
		track_1.stream = playlist[current_song_index % len(playlist)]


func _on_stream_finish():
	current_song_index += 1
	_set_stream()
	track_1.play()
