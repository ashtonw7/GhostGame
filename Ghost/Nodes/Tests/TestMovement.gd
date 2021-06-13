extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = $Player
onready var debug = $CanvasLayer/Debug

var curr_state

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
