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
	"res://levels/Tutorial_1.tscn",
	"res://levels/Tutorial_2.tscn",
	"res://levels/Tutorial_3.tscn",
	"res://levels/Tutorial_4.tscn",
	"res://levels/Tut_OnPlay.tscn",
	"res://levels/Tut_AllOnPlay.tscn",
	"res://levels/Tut_BiggerDance.tscn",
	"res://levels/Goomba_Slide.tscn",
	"res://levels/Tut_BloodStop.tscn",
	"res://levels/Tut_Pull.tscn",
	"res://levels/Tut_Push.tscn"
]
