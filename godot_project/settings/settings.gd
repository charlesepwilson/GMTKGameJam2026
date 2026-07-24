extends Node


var numberwang_index: int = 0
var ray_tracing: bool = false
var controls = null

const minimum_game_speed: float = base_speed / 3
const base_speed: float = 2.5
var game_speed: float = base_speed
const maximum_game_speed: float = 3 * base_speed

const speed_increment: float = 0.2 * base_speed
