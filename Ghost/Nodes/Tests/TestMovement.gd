extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = $Player
onready var camera = $Player/Camera2D
onready var debug = $CanvasLayer/Debug
onready var tiles = $BasicTiles
onready var healthbox = $CanvasLayer/HealthBox

var curr_state

# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect("player_damage", self, "adjust_health")
	set_camera_limits()

func set_camera_limits():
	var map_limits = tiles.get_used_rect()
	var map_cellsize = tiles.cell_size

	camera.limit_left = map_limits.position.x * map_cellsize.x - 52 + 8
	camera.limit_right = map_limits.end.x * map_cellsize.x - 52 - 8
	camera.limit_top = map_limits.position.y * map_cellsize.y + 8
	camera.limit_bottom = map_limits.end.y * map_cellsize.y - 8

func adjust_health():
	healthbox.decrease_health()

func testing():
	if Input.is_action_just_pressed("add_full_heart"):
		healthbox.increase_health(2)
		
	if Input.is_action_just_pressed("add_half_heart"):
		healthbox.increase_health(1)
		
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	curr_state = player.curr_state
	if curr_state == 0:
		debug.text = "MOVING"
	elif curr_state == 1:
		debug.text = "JUMPING"
	elif curr_state == 2:
		debug.text = "DASHING"
	elif curr_state == 3:
		debug.text = "STATIONARY"
		
	testing()
