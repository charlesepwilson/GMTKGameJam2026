extends Button

@onready var sfx: AudioStreamPlayer = $AudioStreamPlayer

const speed_up: float = 4.0

func _ready() -> void:
	var pitch_effect: AudioEffect = AudioServer.get_bus_effect(
		AudioServer.get_bus_index("SpeedUpPitch"),
		0
	) as AudioEffectPitchShift
	pitch_effect.pitch_scale = 1 / speed_up


func _on_pressed():
	sfx.pitch_scale = speed_up
	sfx.play()
