extends Node


var numberwang_index: int = 0
var ray_tracing: bool = false
var controls = null

const minimum_game_speed: float = speed_increment
const base_speed: float = 2.5
var game_speed: float = base_speed
const maximum_game_speed: float = 3 * base_speed

const speed_increment: float = 0.2 * base_speed

func load_level(level_number: int):
    current_level_number = level_number
    get_tree().change_scene_to_file(levels[level_number - 1])

var current_level_number: int = 0

const levels: Array[String] = [
    "res://levels/TutorialLevel.tscn",
    "res://levels/EasyLevel.tscn",
    "res://levels/OnPlayTutorialLevel.tscn",
    "res://levels/AllOnPlayLevel.tscn",
    "res://levels/ExploderIntroLevel.tscn",
    "res://levels/TableIntroLevel.tscn",
    "res://levels/BloodIntroLevel.tscn",
    "res://levels/ExampleLevel.tscn",
]
