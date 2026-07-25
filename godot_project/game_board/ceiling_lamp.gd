extends Light2D

@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var base_energy: float = 1.0
@export var flicker_speed: float = 0.2
@export var intensity: float = 0.35

var time: float = 0.0

func _ready() -> void:
    # Set up basic noise traits for smooth shifting
    noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
    noise.frequency = 2.0

func _process(delta: float) -> void:
    time += delta * flicker_speed
    # Sample noise value between -1.0 and 1.0
    var noise_val = noise.get_noise_1d(time)
    # Apply to light energy smoothly
    energy = base_energy + (noise_val * intensity)
